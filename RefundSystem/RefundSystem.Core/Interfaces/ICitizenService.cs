
namespace RefundSystem.Core.Interfaces;

using DTOs;

public interface ICitizenService
{
    Task<CitizenDto?> GetCitizenByIdNumberAsync(string idNumber);
    Task<IEnumerable<RefundRequestDto>> GetCitizenHistoryAsync(int citizenId);
    Task<object> GetCitizenIncomesAsync(int citizenId);
}
