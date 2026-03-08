
namespace RefundSystem.Core.DTOs;

public record CitizenDto(
    int CitizenId,
    string IdNumber,
    string FirstName,
    string LastName,
    string FullName
);