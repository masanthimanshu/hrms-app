enum ApiEndpoints {
  baseUrl,
  health,
  jwtHealth,
  verifyToken,
  refreshToken,
  storeGet,
  authLogin,
  authUsers,
  uploadImage,
  attendanceAdd,
  attendanceAll,
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
    case ApiEndpoints.authUsers:
      return "account/auth/users";
    case ApiEndpoints.uploadImage:
      return "secure/upload/image";
    case ApiEndpoints.attendanceAdd:
      return "secure/attendance/add";
    case ApiEndpoints.attendanceAll:
      return "secure/attendance/all";
  }
}
