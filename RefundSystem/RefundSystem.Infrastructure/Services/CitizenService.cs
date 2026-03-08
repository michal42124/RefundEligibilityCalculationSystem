using Microsoft.EntityFrameworkCore;
using RefundSystem.Core.DTOs;
using RefundSystem.Core.Interfaces;
using RefundSystem.Infrastructure.Data;

namespace RefundSystem.Infrastructure.Services;

public class CitizenService(AppDbContext context) : ICitizenService
{
    public async Task<CitizenDto?> GetCitizenByIdNumberAsync(string idNumber)
    {
        var citizen = await context.Citizens
            .Where(c => c.IdNumber == idNumber)
            .Select(c => new CitizenDto(
                c.CitizenId,
                c.IdNumber,
                c.FirstName,
                c.LastName,
                c.FirstName + " " + c.LastName
            ))
            .FirstOrDefaultAsync();

        return citizen;
    }

    public async Task<IEnumerable<RefundRequestDto>> GetCitizenHistoryAsync(int citizenId) =>
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

    public async Task<object> GetCitizenIncomesAsync(int citizenId)
    {
        var incomes = await context.MonthlyIncomes
            .Where(i => i.CitizenId == citizenId)
            .GroupBy(i => i.TaxYear)
            .Select(g => new
            {
                TaxYear = g.Key,
                TotalIncome = g.Sum(i => i.IncomeAmount),
                AvgIncome = g.Average(i => i.IncomeAmount),
                MonthsCount = g.Count(),
                Months = g.OrderBy(i => i.Month)
                                 .Select(i => new { i.Month, i.IncomeAmount })
                                 .ToList()
            })
            .OrderByDescending(g => g.TaxYear)
            .ToListAsync();

        return incomes;
    }
}