enum ApiEndpoints { baseUrl, verifyToken, refreshToken }

String apiEndpoint(ApiEndpoints endpoint) {
  switch (endpoint) {
    case ApiEndpoints.baseUrl:
      return "https://hrms.scoobies.ai/";

    case ApiEndpoints.verifyToken:
      return "secure/verify";

    case ApiEndpoints.refreshToken:
      return "jwt/refresh";
  }
}
