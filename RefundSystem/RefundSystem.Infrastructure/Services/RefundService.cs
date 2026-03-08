using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using RefundSystem.Core.DTOs;
using RefundSystem.Core.Interfaces;
using RefundSystem.Infrastructure.Data;
using System.Data;
using System.Reflection.Metadata;


namespace RefundSystem.Infrastructure.Services;

public class RefundService(AppDbContext context) : IRefundService
{
    public async Task<IEnumerable<RefundRequestDto>> GetPendingRequestsAsync() =>
        await context.RefundRequests
            .Include(r => r.Citizen)
            .Where(r => r.Status == "WaitingCalculation")
            .OrderBy(r => r.RequestDate)
            .Select(r => new RefundRequestDto(
                r.RequestId,
                r.CitizenId,
                r.Citizen.FirstName + " " + r.Citizen.LastName,
                r.TaxYear,
                r.Status,
                r.CalculatedAmount,
                r.ApprovedAmount,
                r.RequestDate,
                r.ProcessedAt,
                r.ProcessedBy
            ))
            .ToListAsync();

    public async Task<RefundRequestDto?> GetRequestByIdAsync(int requestId) =>
        await context.RefundRequests
            .Include(r => r.Citizen)
            .Where(r => r.RequestId == requestId)
            .Select(r => new RefundRequestDto(
                r.RequestId,
                r.CitizenId,
                r.Citizen.FirstName + " " + r.Citizen.LastName,
                r.TaxYear,
                r.Status,
                r.CalculatedAmount,
                r.ApprovedAmount,
                r.RequestDate,
                r.ProcessedAt,
                r.ProcessedBy
            ))
            .FirstOrDefaultAsync();

    public async Task<ProcessRequestResultDto> ProcessRequestAsync(int requestId)
    {
        var conn = context.Database.GetDbConnection();
        await conn.OpenAsync();

        await using var cmd = conn.CreateCommand();
        cmd.CommandText = "sp_ProcessRefundRequest";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Parameters.Add(new SqlParameter("@RequestId", requestId));

        await using var reader = await cmd.ExecuteReaderAsync();

        if (await reader.ReadAsync())
        {
            return new ProcessRequestResultDto(
                reader["Result"]?.ToString() ?? "ERROR",
                reader["Message"]?.ToString() ?? "",
                requestId,
                HasColumn(reader, "CalculatedAmount") && reader["CalculatedAmount"] != DBNull.Value
                    ? Convert.ToDecimal(reader["CalculatedAmount"]) : 0,
                HasColumn(reader, "AvailableBudget") && reader["AvailableBudget"] != DBNull.Value
                    ? Convert.ToDecimal(reader["AvailableBudget"]) : 0,
                HasColumn(reader, "BudgetMessage") && reader["BudgetMessage"] != DBNull.Value
                    ? reader["BudgetMessage"].ToString()! : ""
            );
        }

        return new ProcessRequestResultDto("ERROR", "לא התקבלה תשובה", requestId, 0, 0, "");
    }

    public async Task<decimal> GetAvailableBudgetAsync(int year, int month) =>
    await context.MonthlyBudgets
        .Where(b => b.BudgetYear == year && b.BudgetMonth == month)
        .Select(b => b.TotalBudget - b.UsedBudget)
        .FirstOrDefaultAsync();

    public async Task<object> ApproveRequestAsync(int requestId, ApproveRequestDto dto)
    {
        var conn = context.Database.GetDbConnection();
        await conn.OpenAsync();

        await using var cmd = conn.CreateCommand();
        cmd.CommandText = "sp_ApproveRequest";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Parameters.Add(new SqlParameter("@RequestId", requestId));
        cmd.Parameters.Add(new SqlParameter("@IsApproved", dto.IsApproved));
        cmd.Parameters.Add(new SqlParameter("@ProcessedBy", dto.ProcessedBy));
        cmd.Parameters.Add(new SqlParameter("@ProcessingYear", (object?)dto.ProcessingYear ?? DBNull.Value));
        cmd.Parameters.Add(new SqlParameter("@ProcessingMonth", (object?)dto.ProcessingMonth ?? DBNull.Value));

        await using var reader = await cmd.ExecuteReaderAsync();

        if (await reader.ReadAsync())
        {
            var result = new Dictionary<string, object?>
            {
                ["Result"] = reader["Result"]?.ToString(),
                ["Message"] = reader["Message"]?.ToString()
            };

            if (HasColumn(reader, "ApprovedAmount"))
                result["ApprovedAmount"] = reader["ApprovedAmount"] == DBNull.Value ? 0
                    : Convert.ToDecimal(reader["ApprovedAmount"]);

            if (HasColumn(reader, "RemainingBudget") && reader["RemainingBudget"] != DBNull.Value)
                result["RemainingBudget"] = Convert.ToDecimal(reader["RemainingBudget"]);
            else
                result["RemainingBudget"] = (decimal)0;

            return result;
        }

        return new { Result = "ERROR", Message = "לא התקבלה תשובה" };
    }

    public async Task<IEnumerable<RefundRequestDto>> GetCitizenRequestHistoryAsync(int citizenId) =>
    await context.RefundRequests
        .Include(r => r.Citizen)
        .Where(r => r.CitizenId == citizenId)
        .OrderByDescending(r => r.TaxYear)
        .Select(r => new RefundRequestDto(
            r.RequestId,
            r.CitizenId,
            r.Citizen.FirstName + " " + r.Citizen.LastName,
            r.TaxYear,
            r.Status,
            r.CalculatedAmount,
            r.ApprovedAmount,
            r.RequestDate,
            r.ProcessedAt,
            r.ProcessedBy
        ))
        .ToListAsync();

    public async Task<byte[]> ExportApprovedRequestsPdfAsync(int year)
    {
        var requests = await context.RefundRequests
            .Include(r => r.Citizen)
            .Where(r => r.TaxYear == year && r.Status == "Approved")
            .OrderBy(r => r.CitizenId)
            .ToListAsync();

        var document = QuestPDF.Fluent.Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(2, Unit.Centimetre);
                page.ContentFromRightToLeft();
                page.DefaultTextStyle(x => x.FontFamily("Arial").FontSize(11));

                page.Header().Text($"בקשות מאושרות – שנת מס {year}")
                    .SemiBold().FontSize(16).AlignCenter();

                page.Content().Table(table =>
                {
                    table.ColumnsDefinition(columns =>
                    {
                        columns.RelativeColumn(2); // שם אזרח
                        columns.RelativeColumn(2); // תאריך בקשה
                        columns.RelativeColumn(1); // שנת מס
                        columns.RelativeColumn(2); // סכום מאושר
                        columns.RelativeColumn(2); // טופל על ידי
                    });

                    // כותרות טבלה
                    table.Header(header =>
                    {
                        foreach (var title in new[] { "שם אזרח", "תאריך בקשה", "שנת מס", "סכום מאושר", "טופל על ידי" })
                        {
                            header.Cell().Background("#1F3864").Padding(5)
                                .Text(title).FontColor("#FFFFFF").SemiBold().AlignCenter();
                        }
                    });

                    // שורות נתונים
                    var rowColor = true;
                    foreach (var r in requests)
                    {
                        var bg = rowColor ? "#F2F2F2" : "#FFFFFF";
                        rowColor = !rowColor;

                        table.Cell().Background(bg).Padding(5)
                            .Text(r.Citizen.FirstName + " " + r.Citizen.LastName).AlignRight();
                        table.Cell().Background(bg).Padding(5)
                            .Text(r.RequestDate.ToString("dd/MM/yyyy")).AlignCenter();
                        table.Cell().Background(bg).Padding(5)
                            .Text(r.TaxYear.ToString()).AlignCenter();
                        table.Cell().Background(bg).Padding(5)
                            .Text($"₪{r.ApprovedAmount:N0}").AlignCenter();
                        table.Cell().Background(bg).Padding(5)
                            .Text(r.ProcessedBy ?? "—").AlignCenter();
                    }
                });

                page.Footer().AlignCenter()
                    .Text(x =>
                    {
                        x.Span("עמוד ");
                        x.CurrentPageNumber();
                        x.Span(" מתוך ");
                        x.TotalPages();
                    });
            });
        });

        return document.GeneratePdf();
    }

    private static bool HasColumn(IDataReader reader, string columnName)
    {
        for (int i = 0; i < reader.FieldCount; i++)
            if (reader.GetName(i) == columnName) return true;
        return false;
    }
}

