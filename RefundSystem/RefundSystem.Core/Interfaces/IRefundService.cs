
namespace RefundSystem.Core.Interfaces;

using DTOs;

public interface IRefundService
{
    Task<IEnumerable<RefundRequestDto>> GetPendingRequestsAsync();
    Task<RefundRequestDto?> GetRequestByIdAsync(int requestId);
    Task<ProcessRequestResultDto> ProcessRequestAsync(int requestId);
    Task<object> ApproveRequestAsync(int requestId, ApproveRequestDto dto);
    Task<IEnumerable<RefundRequestDto>> GetCitizenRequestHistoryAsync(int citizenId);
    Task<decimal> GetAvailableBudgetAsync(int year, int month);
    Task<byte[]> ExportApprovedRequestsPdfAsync(int year);
}
