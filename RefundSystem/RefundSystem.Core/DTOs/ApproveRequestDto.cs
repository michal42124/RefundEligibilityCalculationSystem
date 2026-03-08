
namespace RefundSystem.Core.DTOs;

public record ApproveRequestDto(
    bool IsApproved,
    string ProcessedBy,
    int? ProcessingYear = null,
    int? ProcessingMonth = null
);
