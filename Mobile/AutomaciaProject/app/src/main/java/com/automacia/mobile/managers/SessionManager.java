package com.automacia.mobile.managers;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import com.automacia.mobile.models.UsuarioDTO;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;

/**
 * Gerencia a sessão do usuário usando Firebase Authentication e SharedPreferences
 *
 * Responsabilidades:
 * - Salvar/recuperar token JWT do Firebase
 * - Gerenciar dados básicos do usuário em sessão
 * - Validar se sessão está ativa
 * - Logout completo (Firebase + dados locais)
 */
public class SessionManager {

    private static final String TAG = "SessionManager";
    private static final String PREF_NAME = "AutomaciaSession";

    // Chaves do SharedPreferences
    private static final String KEY_IS_LOGGED_IN = "is_logged_in";
    private static final String KEY_FIREBASE_UID = "firebase_uid";
    private static final String KEY_USER_CPF = "user_cpf";
    private static final String KEY_USER_EMAIL = "user_email";
    private static final String KEY_USER_NOME = "user_nome";
    private static final String KEY_USER_NOME_SOCIAL = "user_nome_social";
    private static final String KEY_USER_TELEFONE = "user_telefone";
    private static final String KEY_LAST_LOGIN = "last_login_timestamp";

    private final SharedPreferences preferences;
    private final SharedPreferences.Editor editor;
    private final FirebaseAuth firebaseAuth;

    /**
     * Construtor - Inicializa SharedPreferences e FirebaseAuth
     */
    public SessionManager(Context context) {
        this.preferences = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
        this.editor = preferences.edit();
        this.firebaseAuth = FirebaseAuth.getInstance();

        Log.d(TAG, "SessionManager inicializado");
    }

    // ==================== SALVAR SESSÃO ====================

    /**
     * Salva a sessão completa do usuário após login bem-sucedido
     *
     * @param usuario Dados do usuário vindos do SQL Server
     * @param firebaseUser Usuário autenticado no Firebase
     */
    public void createSession(UsuarioDTO usuario, FirebaseUser firebaseUser) {
        if (usuario == null || firebaseUser == null) {
            Log.e(TAG, "Tentativa de criar sessão com dados nulos");
            return;
        }

        editor.putBoolean(KEY_IS_LOGGED_IN, true);
        editor.putString(KEY_FIREBASE_UID, firebaseUser.getUid());
        editor.putString(KEY_USER_CPF, usuario.getCpf());
        editor.putString(KEY_USER_EMAIL, usuario.getEmail());
        editor.putString(KEY_USER_NOME, usuario.getNome());
        editor.putString(KEY_USER_NOME_SOCIAL, usuario.getNomeSocial());
        editor.putString(KEY_USER_TELEFONE, usuario.getTelefone());
        editor.putLong(KEY_LAST_LOGIN, System.currentTimeMillis());
        editor.apply();

        Log.i(TAG, "Sessão criada para usuário: " + usuario.getCpf());
    }

    // ==================== VALIDAÇÃO DE SESSÃO ====================

    /**
     * Verifica se existe uma sessão ativa válida
     * Valida tanto o SharedPreferences quanto o Firebase
     *
     * @return true se sessão válida, false caso contrário
     */
    public boolean isSessionActive() {
        boolean isLoggedIn = preferences.getBoolean(KEY_IS_LOGGED_IN, false);
        FirebaseUser firebaseUser = firebaseAuth.getCurrentUser();

        boolean sessionValid = isLoggedIn && firebaseUser != null;

        if (sessionValid) {
            Log.d(TAG, "Sessão ativa encontrada para UID: " + firebaseUser.getUid());
        } else {
            Log.d(TAG, "Nenhuma sessão ativa encontrada");
        }

        return sessionValid;
    }

    /**
     * Verifica se o token do Firebase ainda é válido
     * Nota: Firebase gerencia expiração automaticamente
     *
     * @param callback Callback com resultado da validação
     */
    public void validateToken(TokenValidationCallback callback) {
        FirebaseUser currentUser = firebaseAuth.getCurrentUser();

        if (currentUser == null) {
            Log.w(TAG, "Nenhum usuário Firebase autenticado");
            callback.onInvalid();
            return;
        }

        // Tenta obter token atual (Firebase renova automaticamente se necessário)
        currentUser.getIdToken(false)
                .addOnSuccessListener(result -> {
                    String token = result.getToken();
                    long expirationTime = result.getExpirationTimestamp();

                    Log.d(TAG, "Token válido. Expira em: " +
                            new java.util.Date(expirationTime));

                    callback.onValid(token, expirationTime);
                })
                .addOnFailureListener(e -> {
                    Log.e(TAG, "Falha ao validar token: " + e.getMessage());
                    callback.onInvalid();
                });
    }

    /**
     * Força renovação do token do Firebase
     *
     * @param callback Callback com novo token ou erro
     */
    public void forceRefreshToken(TokenValidationCallback callback) {
        FirebaseUser currentUser = firebaseAuth.getCurrentUser();

        if (currentUser == null) {
            Log.w(TAG, "Nenhum usuário para renovar token");
            callback.onInvalid();
            return;
        }

        // força refresh (true)
        currentUser.getIdToken(true)
                .addOnSuccessListener(result -> {
                    String newToken = result.getToken();
                    Log.i(TAG, "Token renovado com sucesso");
                    callback.onValid(newToken, result.getExpirationTimestamp());
                })
                .addOnFailureListener(e -> {
                    Log.e(TAG, "Falha ao renovar token: " + e.getMessage());
                    callback.onInvalid();
                });
    }

    // ==================== RECUPERAR DADOS ====================

    /**
     * Recupera o UsuarioDTO salvo na sessão
     * Nota: Dados completos ficam no MyApp.usuarioLogado
     *
     * @return UsuarioDTO básico ou null se não houver sessão
     */
    public UsuarioDTO getUsuarioFromSession() {
        if (!isSessionActive()) {
            return null;
        }

        UsuarioDTO usuario = new UsuarioDTO();
        usuario.setCpf(preferences.getString(KEY_USER_CPF, ""));
        usuario.setEmail(preferences.getString(KEY_USER_EMAIL, ""));
        usuario.setNome(preferences.getString(KEY_USER_NOME, ""));
        usuario.setNomeSocial(preferences.getString(KEY_USER_NOME_SOCIAL, ""));
        usuario.setTelefone(preferences.getString(KEY_USER_TELEFONE, ""));

        return usuario;
    }

    /**
     * Retorna o CPF do usuário logado
     */
    public String getUserCpf() {
        return preferences.getString(KEY_USER_CPF, null);
    }

    /**
     * Retorna o email do usuário logado
     */
    public String getUserEmail() {
        return preferences.getString(KEY_USER_EMAIL, null);
    }

    /**
     * Retorna o Firebase UID do usuário logado
     */
    public String getFirebaseUid() {
        return preferences.getString(KEY_FIREBASE_UID, null);
    }

    /**
     * Retorna o timestamp do último login
     */
    public long getLastLoginTimestamp() {
        return preferences.getLong(KEY_LAST_LOGIN, 0);
    }

    // ==================== LOGOUT ====================

    /**
     * Realiza logout completo:
     * - Desloga do Firebase
     * - Limpa SharedPreferences
     * - Remove dados da memória (MyApp)
     *
     * @param context Context para acessar MyApp
     */
    public void logout(Context context) {
        Log.i(TAG, "Iniciando logout completo...");

        // 1. Logout do Firebase
        try {
            firebaseAuth.signOut();
            Log.d(TAG, "Firebase signOut executado");
        } catch (Exception e) {
            Log.e(TAG, "Erro ao deslogar do Firebase: " + e.getMessage());
        }

        // 2. Limpar SharedPreferences
        clearSessionData();

        // 3. Limpar dados globais do MyApp
        try {
            com.automacia.mobile.MyApp app =
                    (com.automacia.mobile.MyApp) context.getApplicationContext();
            app.setUsuarioLogado(null);
            Log.d(TAG, "Dados globais limpos (MyApp)");
        } catch (Exception e) {
            Log.e(TAG, "Erro ao limpar MyApp: " + e.getMessage());
        }

        Log.i(TAG, "Logout completo executado com sucesso");
    }

    /**
     * Limpa apenas os dados do SharedPreferences
     * Usado internamente e em casos específicos
     */
    public void clearSessionData() {
        editor.clear();
        editor.apply();
        Log.d(TAG, "SharedPreferences limpo");
    }

    /**
     * Limpa dados sensíveis mas mantém preferências básicas
     * (Ex: manter tema, idioma, etc se tiver)
     */
    public void clearSensitiveData() {
        editor.remove(KEY_IS_LOGGED_IN);
        editor.remove(KEY_FIREBASE_UID);
        editor.remove(KEY_USER_CPF);
        editor.remove(KEY_USER_EMAIL);
        editor.remove(KEY_USER_NOME);
        editor.remove(KEY_USER_NOME_SOCIAL);
        editor.remove(KEY_USER_TELEFONE);
        editor.remove(KEY_LAST_LOGIN);
        editor.apply();

        Log.d(TAG, "Dados sensíveis removidos");
    }

    // ==================== HELPERS ====================

    /**
     * Retorna o FirebaseAuth instance (para uso externo se necessário)
     */
    public FirebaseAuth getFirebaseAuth() {
        return firebaseAuth;
    }

    /**
     * Verifica se o token expirou (baseado no tempo do Firebase)
     * Token do Firebase expira após 1 hora por padrão
     *
     * @return true se expirado
     */
    public boolean isTokenExpired() {
        FirebaseUser user = firebaseAuth.getCurrentUser();
        if (user == null) {
            return true;
        }

        // Firebase cuida disso automaticamente, mas podemos expor para debug
        // Não temos acesso direto ao tempo de expiração sem fazer getIdToken
        // Então retornamos false aqui (Firebase gerencia internamente)
        return false;
    }

    // ==================== CALLBACKS ====================

    /**
     * Interface para callback de validacao de token
     */
    public interface TokenValidationCallback {
        void onValid(String token, long expirationTime);
        void onInvalid();
    }

    // ==================== DEBUG ====================

    /**
     * Metodo para debug - mostra informações da sessão
     */
    public void printSessionInfo() {
        Log.d(TAG, "========== SESSION INFO ==========");
        Log.d(TAG, "Is Logged In: " + preferences.getBoolean(KEY_IS_LOGGED_IN, false));
        Log.d(TAG, "Firebase UID: " + preferences.getString(KEY_FIREBASE_UID, "null"));
        Log.d(TAG, "User CPF: " + preferences.getString(KEY_USER_CPF, "null"));
        Log.d(TAG, "User Email: " + preferences.getString(KEY_USER_EMAIL, "null"));
        Log.d(TAG, "Firebase User: " + (firebaseAuth.getCurrentUser() != null ?
                "Authenticated" : "Not authenticated"));
        Log.d(TAG, "==================================");
    }
}