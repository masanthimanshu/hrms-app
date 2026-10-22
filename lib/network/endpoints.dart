enum ApiEndpoints {
  baseUrl,
  health,
  jwtHealth,
  verifyToken,
  refreshToken,
  storeCreate,
  storeGet,
  authCreate,
  authLogin,
}

String apiEndpoint(ApiEndpoints endpoint) {
  switch (endpoint) {
    case ApiEndpoints.baseUrl:
      return "https://hrms.scoobies.ai/app/";

    case ApiEndpoints.health:
      return "health";

    case ApiEndpoints.jwtHealth:
      return "jwt/health";

    case ApiEndpoints.verifyToken:
      return "secure/verify";

    case ApiEndpoints.refreshToken:
      return "jwt/refresh";

    case ApiEndpoints.storeCreate:
      return "account/store/create";

    case ApiEndpoints.storeGet:
      return "account/store/get";

    case ApiEndpoints.authCreate:
      return "account/auth/create";

    case ApiEndpoints.authLogin:
      return "account/auth/login";
  }
}
