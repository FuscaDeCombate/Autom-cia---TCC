package com.automacia.mobile.services;

import android.util.Log;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseUser;

/**
 * Serviço responsável por operações de autenticação Firebase
 * focado em LOGIN e gerenciamento de TOKENS
 *
 * Nota: RegisterService já cuida de cadastro e verificação de email
 * Este service foca em:
 * - Login com email/senha
 * - Obtenção e validação de tokens JWT
 * - Verificação de estado de autenticação
 * - Logout
 */
public class FirebaseAuthService {

    private static final String TAG = "FirebaseAuthService";
    private static final FirebaseAuth firebaseAuth = FirebaseAuth.getInstance();

    // ==================== LOGIN ====================

    /**
     * Realiza login no Firebase usando email e senha
     * Deve ser chamado APÓS validação bem-sucedida no SQL Server
     *
     * @param email Email do usuário
     * @param senha Senha do usuário (mesma usada no SQL)
     * @param callback Callback com resultado do login
     */
    public static void signInWithEmailPassword(String email, String senha,
                                               FirebaseAuthCallback callback) {
        if (email == null || email.isEmpty() || senha == null || senha.isEmpty()) {
            Log.e(TAG, "Email ou senha vazios");
            callback.onError("Dados de autenticação inválidos");
            return;
        }

        Log.d(TAG, "Tentando autenticar no Firebase: " + email);

        firebaseAuth.signInWithEmailAndPassword(email, senha)
                .addOnSuccessListener(authResult -> {
                    FirebaseUser user = authResult.getUser();
                    if (user != null) {
                        Log.i(TAG, "Login Firebase bem-sucedido. UID: " + user.getUid());
                        callback.onSuccess(user);
                    } else {
                        Log.e(TAG, "AuthResult sem usuário");
                        callback.onError("Erro na autenticação Firebase");
                    }
                })
                .addOnFailureListener(e -> {
                    String errorMessage = interpretFirebaseError(e);
                    Log.e(TAG, "Falha no login Firebase: " + errorMessage, e);
                    callback.onError(errorMessage);
                });
    }

    // ==================== TOKEN JWT ====================

    /**
     * Obtém o token JWT atual do usuário autenticado
     * Firebase gerencia renovação automaticamente
     *
     * @param forceRefresh Se true, força renovação do token
     * @param callback Callback com token ou erro
     */
    public static void getIdToken(boolean forceRefresh, TokenCallback callback) {
        FirebaseUser user = firebaseAuth.getCurrentUser();

        if (user == null) {
            Log.w(TAG, "Nenhum usuário autenticado para obter token");
            callback.onError("Usuário não autenticado");
            return;
        }

        user.getIdToken(forceRefresh)
                .addOnSuccessListener(result -> {
                    String token = result.getToken();
                    long expirationTime = result.getExpirationTimestamp();

                    Log.d(TAG, "Token obtido. Expira em: " +
                            new java.util.Date(expirationTime));

                    callback.onSuccess(token, expirationTime);
                })
                .addOnFailureListener(e -> {
                    Log.e(TAG, "Erro ao obter token", e);
                    callback.onError("Falha ao obter token: " + e.getMessage());
                });
    }

    // ==================== ESTADO ====================

    /**
     * Retorna o usuário Firebase atualmente autenticado
     *
     * @return FirebaseUser ou null se não autenticado
     */
    public static FirebaseUser getCurrentUser() {
        return firebaseAuth.getCurrentUser();
    }

    /**
     * Verifica se existe um usuário autenticado
     */
    public static boolean isUserAuthenticated() {
        return firebaseAuth.getCurrentUser() != null;
    }

    /**
     * Retorna o UID do usuário atual
     */
    public static String getCurrentUserId() {
        FirebaseUser user = firebaseAuth.getCurrentUser();
        return user != null ? user.getUid() : null;
    }

    /**
     * Retorna o email do usuário atual
     */
    public static String getCurrentUserEmail() {
        FirebaseUser user = firebaseAuth.getCurrentUser();
        return user != null ? user.getEmail() : null;
    }

    /**
     * Verifica se o email do usuário atual foi verificado
     */
    public static boolean isEmailVerified() {
        FirebaseUser user = firebaseAuth.getCurrentUser();
        return user != null && user.isEmailVerified();
    }

    // ==================== LOGOUT ====================

    /**
     * Desloga do Firebase Authentication
     * Nota: SessionManager.logout() deve ser usado para logout completo
     */
    public static void signOut() {
        try {
            firebaseAuth.signOut();
            Log.i(TAG, "Firebase signOut executado");
        } catch (Exception e) {
            Log.e(TAG, "Erro ao executar signOut", e);
        }
    }

    // ==================== TRATAMENTO DE ERROS ====================

    /**
     * Interpreta erros do Firebase para mensagens amigáveis em português
     * Focado em erros de LOGIN (cadastro está no RegisterService)
     */
    private static String interpretFirebaseError(Exception e) {
        if (!(e instanceof FirebaseAuthException)) {
            return "Erro de autenticação: " + e.getMessage();
        }

        FirebaseAuthException authException = (FirebaseAuthException) e;
        String errorCode = authException.getErrorCode();

        switch (errorCode) {
            // Erros de login
            case "ERROR_INVALID_EMAIL":
                return "Email inválido";

            case "ERROR_WRONG_PASSWORD":
                return "Senha incorreta";

            case "ERROR_USER_NOT_FOUND":
                return "Usuário não encontrado. Verifique se você já se cadastrou.";

            case "ERROR_USER_DISABLED":
                return "Esta conta foi desabilitada. Entre em contato com o suporte.";

            case "ERROR_TOO_MANY_REQUESTS":
                return "Muitas tentativas de login. Aguarde alguns minutos e tente novamente.";

            case "ERROR_INVALID_CREDENTIAL":
                return "Credenciais inválidas";

            // Erros de rede
            case "ERROR_NETWORK_REQUEST_FAILED":
                return "Erro de conexão. Verifique sua internet.";

            // Outros erros
            default:
                Log.w(TAG, "Código de erro não mapeado: " + errorCode);
                return "Erro de autenticação (" + errorCode + ")";
        }
    }

    // ==================== CALLBACKS ====================

    /**
     * Callback para operações de autenticação (login)
     */
    public interface FirebaseAuthCallback {
        void onSuccess(FirebaseUser user);
        void onError(String errorMessage);
    }

    /**
     * Callback para obtenção de token JWT
     */
    public interface TokenCallback {
        void onSuccess(String token, long expirationTime);
        void onError(String errorMessage);
    }

    // ==================== HELPERS ====================

    /**
     * Retorna instância do FirebaseAuth (para uso avançado)
     */
    public static FirebaseAuth getFirebaseAuth() {
        return firebaseAuth;
    }

    /**
     * Recarrega o estado do usuário atual do Firebase
     * Útil para verificar se o email foi verificado após o usuário clicar no link
     *
     * @param callback Callback com resultado
     */
    public static void reloadCurrentUser(ReloadCallback callback) {
        FirebaseUser user = firebaseAuth.getCurrentUser();

        if (user == null) {
            Log.w(TAG, "Nenhum usuário para recarregar");
            callback.onError("Usuário não autenticado");
            return;
        }

        user.reload()
                .addOnSuccessListener(aVoid -> {
                    Log.d(TAG, "Usuário recarregado com sucesso");
                    callback.onSuccess(user);
                })
                .addOnFailureListener(e -> {
                    Log.e(TAG, "Erro ao recarregar usuário", e);
                    callback.onError("Erro ao atualizar dados do usuário");
                });
    }

    /**
     * Callback para reload de usuário
     */
    public interface ReloadCallback {
        void onSuccess(FirebaseUser user);
        void onError(String errorMessage);
    }
}