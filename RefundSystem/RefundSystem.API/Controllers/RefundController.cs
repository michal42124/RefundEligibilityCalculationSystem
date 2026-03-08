using Microsoft.AspNetCore.Mvc;
using RefundSystem.Core.DTOs;
using RefundSystem.Core.Interfaces;
using Microsoft.AspNetCore.SignalR;
using RefundSystem.API.Hubs;
namespace RefundSystem.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class RefundController(IRefundService refundService, IHubContext<BudgetHub> hubContext) : ControllerBase
{
    // מסך פקיד – כל הבקשות הממתינות
    [HttpGet("pending")]
    public async Task<ActionResult<IEnumerable<RefundRequestDto>>> GetPendingRequests()
    {
        var requests = await refundService.GetPendingRequestsAsync();
        return Ok(requests);
    }

    // מסך פקיד – פרטי בקשה ספציפית
    [HttpGet("{requestId}")]
    public async Task<ActionResult<RefundRequestDto>> GetRequest(int requestId)
    {
        var request = await refundService.GetRequestByIdAsync(requestId);
        return request is null ? NotFound() : Ok(request);
    }


    // כפתור חשב – חישוב זכאות
    [HttpPost("{requestId}/process")]
    public async Task<ActionResult<ProcessRequestResultDto>> ProcessRequest(int requestId)
    {
        var result = await refundService.ProcessRequestAsync(requestId);
        return Ok(result);
    }

    // מסך פקיד -תקציב קיים
    [HttpGet("budget/{year}/{month}")]
    public async Task<ActionResult> GetBudget(int year, int month)
    {
        var budget = await refundService.GetAvailableBudgetAsync(year, month);
        return Ok(budget);
    }



    // כפתור אשר/דחה – החלטת פקיד
    [HttpPost("{requestId}/approve")]
    public async Task<ActionResult> ApproveRequest(int requestId, ApproveRequestDto dto)
    {
        var result = await refundService.ApproveRequestAsync(requestId, dto);

        // שלח עדכון תקציב לכל הלקוחות
        if (result is Dictionary<string, object?> dict &&
            dict.TryGetValue("Result", out var resultVal) &&
            resultVal?.ToString() == "APPROVED" &&
            dict.TryGetValue("RemainingBudget", out var remaining))
        {
            await hubContext.Clients.All.SendAsync("BudgetUpdated", new
            {
                Year = dto.ProcessingYear,
                Month = dto.ProcessingMonth,
                RemainingBudget = remaining
            });
        }

        return Ok(result);
    }

    // ייצוא בקשות מאושרות לפי שנת מס
    [HttpGet("export/pdf/{year}")]
    public async Task<ActionResult> ExportApprovedPdf(int year)
    {
        var pdfBytes = await refundService.ExportApprovedRequestsPdfAsync(year);
        return File(pdfBytes, "application/pdf", $"approved_requests_{year}.pdf");
    }
}
