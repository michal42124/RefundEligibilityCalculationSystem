
namespace RefundSystem.Core.DTOs;

public record RefundRequestDto(
    int RequestId,
    int CitizenId,
    string CitizenFullName,
    int TaxYear,
    string Status,
    decimal? CalculatedAmount,
    decimal ApprovedAmount,
    DateTime RequestDate,
    DateTime? ProcessedAt,
    string? ProcessedBy
);
