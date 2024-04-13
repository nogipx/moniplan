abstract class IMapper<Domain, Dto> {
  Dto toDto(Domain data);
  Domain toDomain(Dto data);
}
