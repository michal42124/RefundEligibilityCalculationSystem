using Microsoft.AspNetCore.Mvc;
using RefundSystem.Core.DTOs;
using RefundSystem.Core.Interfaces;
namespace RefundSystem.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CitizenController(ICitizenService citizenService) : ControllerBase
{
    // מסך אזרח – חיפוש לפי תעודת זהות
    [HttpGet("{idNumber}")]
    public async Task<ActionResult<CitizenDto>> GetCitizen(string idNumber)
    {
        var citizen = await citizenService.GetCitizenByIdNumberAsync(idNumber);
        return citizen is null ? NotFound() : Ok(citizen);
    }

    // מסך אזרח – היסטוריית בקשות
    [HttpGet("{citizenId}/history")]
    public async Task<ActionResult<IEnumerable<RefundRequestDto>>> GetCitizenHistory(int citizenId)
    {
        var history = await citizenService.GetCitizenHistoryAsync(citizenId);
        return Ok(history);
    }

    // מסך פקיד – הכנסות עבר של האזרח
    [HttpGet("{citizenId}/incomes")]
    public async Task<ActionResult> GetCitizenIncomes(int citizenId)
    {
        var incomes = await citizenService.GetCitizenIncomesAsync(citizenId);
        return Ok(incomes);
    }
}
