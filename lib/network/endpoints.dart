enum ApiEndpoints {
  baseUrl,
  health,
  jwtHealth,
  verifyToken,
  refreshToken,
  storeGet,
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
    case ApiEndpoints.storeGet:
      return "account/store/get";
    case ApiEndpoints.authLogin:
      return "account/auth/login";
  }
}
