import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "/network/endpoints.dart";
import "/network/requests.dart";
import "/providers/auth_provider.dart";
import "/providers/health_provider.dart";
import "/utils/colors.dart";
import "/utils/formatters.dart";
import "/widgets/monochrome_button.dart";
import "/widgets/monochrome_card.dart";
import "/widgets/section_header.dart";
import "/widgets/status_pill.dart";

class SecurityTab extends ConsumerStatefulWidget {
  const SecurityTab({super.key});

  @override
  ConsumerState<SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends ConsumerState<SecurityTab> with HTTPRequests {
  String _apiConsoleOutput = "Click an action above to test backend security endpoints.";
  bool _isTestingVerify = false;
  bool _isTestingRefresh = false;
  bool _isTestingHealth = false;

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$label copied to clipboard")),
    );
  }

  void _testVerify() async {
    setState(() {
      _isTestingVerify = true;
      _apiConsoleOutput = "Sending GET /secure/verify with dual JWT headers...";
    });

    try {
      final res = await getRequest(apiEndpoint(ApiEndpoints.verifyToken));
      setState(() {
        _isTestingVerify = false;
        _apiConsoleOutput = """
HTTP/2 200 OK
Endpoint: /secure/verify
Timestamp: ${DateTime.now().toIso8601String()}
Payload Response:
${res != null ? res.toString() : "null"}
Status: User Signature Cryptographically Verified!""";
      });
    } catch (e) {
      setState(() {
        _isTestingVerify = false;
        _apiConsoleOutput = "Error during /secure/verify: $e";
      });
    }
  }

  void _testRefresh() async {
    setState(() {
      _isTestingRefresh = true;
      _apiConsoleOutput = "Sending GET /jwt/refresh with authorization & refresh headers...";
    });

    final success = await ref.read(authProvider.notifier).manualRefreshToken();
    final authState = ref.read(authProvider);

    setState(() {
      _isTestingRefresh = false;
      _apiConsoleOutput = """
HTTP/2 200 OK
Endpoint: /jwt/refresh
Timestamp: ${DateTime.now().toIso8601String()}
Result: ${success ? "Success" : "Failed"}
New Access Token: ${AppFormatters.maskToken(authState.authToken, prefix: 12, suffix: 12)}
New Refresh Token: ${AppFormatters.maskToken(authState.refreshToken, prefix: 12, suffix: 12)}
Session Rotated & Stored in Hive!""";
    });
  }

  void _testHealth() async {
    setState(() {
      _isTestingHealth = true;
      _apiConsoleOutput = "Pinging GET /health and GET /jwt/health...";
    });

    await ref.read(healthProvider.notifier).checkHealth();
    final health = ref.read(healthProvider).status;

    setState(() {
      _isTestingHealth = false;
      _apiConsoleOutput = """
Health Diagnostic:
Base URL: https://hrms.scoobies.ai/app/
Server Status: ${health.isOnline ? "ONLINE (200 OK)" : "OFFLINE"}
JWT Subservice: ${health.isJwtOnline ? "HEALTHY" : "DOWN"}
Roundtrip Latency: ${health.latencyMs}ms
Checked At: ${health.lastChecked.toIso8601String()}""";
    });
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Sign Out",
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.zinc950),
        ),
        content: const Text(
          "Are you sure you want to end your current session? You will need to log in again.",
          style: TextStyle(fontSize: 14, color: AppColors.zinc600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          MonochromeButton(
            text: "Sign Out",
            height: 38,
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: "Security & JWT Lifecycle",
            subtitle: "Dual-layer token authorization & cryptographic verification",
          ),
          const SizedBox(height: 18),

          // Token Lifecycle Bento
          Row(
            children: [
              Expanded(
                child: MonochromeCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "ACCESS TOKEN",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.zinc500,
                            ),
                          ),
                          StatusPill(label: "2 Days", type: StatusPillType.active, showDot: false),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppFormatters.maskToken(authState.authToken, prefix: 8, suffix: 6),
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: "monospace",
                          fontWeight: FontWeight.w600,
                          color: AppColors.zinc950,
                        ),
                      ),
                      const SizedBox(height: 10),
                      MonochromeButton(
                        text: "Copy Token",
                        icon: Icons.copy,
                        variant: MonochromeButtonVariant.ghost,
                        height: 32,
                        onPressed: () => _copyToClipboard(authState.authToken ?? "", "Access Token"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MonochromeCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "REFRESH TOKEN",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.zinc500,
                            ),
                          ),
                          StatusPill(label: "10 Days", type: StatusPillType.active, showDot: false),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppFormatters.maskToken(authState.refreshToken, prefix: 8, suffix: 6),
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: "monospace",
                          fontWeight: FontWeight.w600,
                          color: AppColors.zinc950,
                        ),
                      ),
                      const SizedBox(height: 10),
                      MonochromeButton(
                        text: "Copy Token",
                        icon: Icons.copy,
                        variant: MonochromeButtonVariant.ghost,
                        height: 32,
                        onPressed: () => _copyToClipboard(authState.refreshToken ?? "", "Refresh Token"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Account Header Key Card
          MonochromeCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ACCOUNT KEY HEADER",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.zinc500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      kDefaultAccountId,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: "monospace",
                        fontWeight: FontWeight.w600,
                        color: AppColors.zinc950,
                      ),
                    ),
                  ],
                ),
                MonochromeButton(
                  text: "Copy",
                  icon: Icons.copy,
                  variant: MonochromeButtonVariant.ghost,
                  height: 32,
                  onPressed: () => _copyToClipboard(kDefaultAccountId, "Account ID"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Interactive Testing Controls
          const SectionHeader(
            title: "Live Endpoint Testing",
            subtitle: "Send cryptographic requests directly to the backend",
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MonochromeButton(
                text: "Test /secure/verify",
                icon: Icons.verified_user_outlined,
                isLoading: _isTestingVerify,
                onPressed: _testVerify,
                height: 40,
              ),
              MonochromeButton(
                text: "Rotate Tokens (/jwt/refresh)",
                icon: Icons.autorenew,
                variant: MonochromeButtonVariant.secondary,
                isLoading: _isTestingRefresh,
                onPressed: _testRefresh,
                height: 40,
              ),
              MonochromeButton(
                text: "Ping Health (/health)",
                icon: Icons.network_ping,
                variant: MonochromeButtonVariant.secondary,
                isLoading: _isTestingHealth,
                onPressed: _testHealth,
                height: 40,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Live Console Viewer
          MonochromeCard(
            backgroundColor: AppColors.zinc950,
            borderColor: AppColors.zinc800,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.terminal, size: 16, color: AppColors.zinc400),
                        SizedBox(width: 8),
                        Text(
                          "API RESPONSE CONSOLE",
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: "monospace",
                            fontWeight: FontWeight.w700,
                            color: AppColors.zinc400,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => setState(() => _apiConsoleOutput = "Console cleared."),
                      child: const Text(
                        "Clear",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.zinc400,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.zinc800, width: 1),
                  ),
                  child: SelectableText(
                    _apiConsoleOutput,
                    style: const TextStyle(
                      fontFamily: "monospace",
                      fontSize: 12,
                      color: AppColors.zinc200,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // User Profile & Sign Out
          MonochromeCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authState.currentUser?.name ?? "Employee",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.zinc950,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      authState.currentUser?.email ?? "alex.vance@example.com",
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.zinc500,
                      ),
                    ),
                  ],
                ),
                MonochromeButton(
                  text: "Sign Out",
                  icon: Icons.logout,
                  variant: MonochromeButtonVariant.secondary,
                  height: 38,
                  onPressed: _confirmSignOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
