
namespace RefundSystem.Core.DTOs;

public record ProcessRequestResultDto(
    string Result,
    string Message,
    int RequestId,
    decimal CalculatedAmount,
    decimal AvailableBudget,
    string BudgetMessage
);
