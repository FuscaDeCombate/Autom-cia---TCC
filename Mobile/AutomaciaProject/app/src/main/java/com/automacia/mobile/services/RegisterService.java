package com.automacia.mobile.services;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.automacia.mobile.models.UsuarioDTO;
import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.ActionCodeSettings;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Service responsável pelas operações de cadastro de usuários
 * Utiliza Firebase Authentication para autenticação e verificação de email
 * Implementa operações assíncronas para não bloquear a UI
 */
public class RegisterService {

    private static final String TAG = "RegisterService";
    private final ExecutorService executor;
    private final Handler mainHandler;
    private FirebaseAuth firebaseAuth;

    // URL de fallback - pode ser qualquer URL válida ou o domínio do seu Firebase Hosting
    private static final String FALLBACK_URL = "https://automacia-4ec6b.firebaseapp.com";

    public RegisterService(Context context) {
        executor = Executors.newSingleThreadExecutor();
        mainHandler = new Handler(Looper.getMainLooper());
        initializeFirebase(context);
    }

    private void initializeFirebase(Context context) {
        try {
            FirebaseApp.getInstance();
            firebaseAuth = FirebaseAuth.getInstance();
        } catch (IllegalStateException e) {
            Log.d(TAG, "Inicializando Firebase...");
            FirebaseApp.initializeApp(context);
            firebaseAuth = FirebaseAuth.getInstance();
        }
    }

    // Callbacks
    public interface RegisterCallback {
        void onSuccess(String message);
        void onError(String error);
        void onLoading(boolean isLoading);
        void onEmailVerificationSent(String email);
    }

    public interface CheckExistenceCallback {
        void onResult(boolean ok, String field);
        void onError(String error);
    }

    public interface DatabaseCallback {
        void onSuccess(String message);
        void onError(String error);
        void onLoading(boolean isLoading);
    }

    /**
     * Cria ActionCodeSettings para links de verificação
     */
    private ActionCodeSettings criarActionCodeSettings() {
        return ActionCodeSettings.newBuilder()
                .setUrl(FALLBACK_URL) // URL de fallback
                .setHandleCodeInApp(true)
                .setAndroidPackageName(
                        "com.automacia.mobile", // Seu package name
                        true, // installIfNotAvailable
                        null  // minimumVersion
                )
                .build();
    }

    /**
     * Registra um novo usuário usando Firebase Authentication
     * O Firebase gerará automaticamente o link de verificação correto
     */
    public void registrarUsuario(UsuarioDTO usuario, RegisterCallback callback) {
        if (firebaseAuth == null) {
            callback.onError("Firebase não está inicializado");
            return;
        }

        mainHandler.post(() -> callback.onLoading(true));

        firebaseAuth.createUserWithEmailAndPassword(usuario.getEmail(), usuario.getSenha())
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        FirebaseUser firebaseUser = firebaseAuth.getCurrentUser();
                        if (firebaseUser != null) {
                            ActionCodeSettings actionCodeSettings = criarActionCodeSettings();

                            // O Firebase enviará automaticamente o email com o link correto
                            firebaseUser.sendEmailVerification(actionCodeSettings)
                                    .addOnCompleteListener(emailTask -> {
                                        mainHandler.post(() -> callback.onLoading(false));

                                        if (emailTask.isSuccessful()) {
                                            Log.d(TAG, "Link de verificação enviado automaticamente pelo Firebase para: " + usuario.getEmail());
                                            mainHandler.post(() -> {
                                                callback.onEmailVerificationSent(usuario.getEmail());
                                                callback.onSuccess("Link de verificação enviado! Verifique sua caixa de entrada.");
                                            });
                                        } else {
                                            Log.e(TAG, "Erro ao enviar link de verificação", emailTask.getException());
                                            mainHandler.post(() ->
                                                    callback.onError("Erro ao enviar email de confirmação. Tente novamente.")
                                            );
                                        }
                                    });
                        }
                    } else {
                        String errorMessage = mapearErroFirebase(task.getException());
                        Log.e(TAG, "Erro ao criar conta Firebase", task.getException());
                        mainHandler.post(() -> {
                            callback.onLoading(false);
                            callback.onError(errorMessage);
                        });
                    }
                });
    }

    /**
     * Reenvia link de verificação
     */
    public void reenviarLinkVerificacao(RegisterCallback callback) {
        if (firebaseAuth == null) {
            callback.onError("Firebase não está inicializado");
            return;
        }

        FirebaseUser currentUser = firebaseAuth.getCurrentUser();
        if (currentUser != null) {
            ActionCodeSettings actionCodeSettings = criarActionCodeSettings();

            currentUser.sendEmailVerification(actionCodeSettings)
                    .addOnCompleteListener(task -> {
                        if (task.isSuccessful()) {
                            Log.d(TAG, "Link de verificação reenviado automaticamente pelo Firebase");
                            mainHandler.post(() -> {
                                callback.onEmailVerificationSent(currentUser.getEmail());
                                callback.onSuccess("Link de verificação reenviado! Verifique sua caixa de entrada.");
                            });
                        } else {
                            Log.e(TAG, "Erro ao reenviar verificação", task.getException());
                            mainHandler.post(() ->
                                    callback.onError("Erro ao reenviar link de verificação")
                            );
                        }
                    });
        } else {
            callback.onError("Usuário não está logado");
        }
    }

    /**
     * Processa link recebido no app via deep link
     */
    public void processarLinkVerificacao(String linkRecebido, RegisterCallback callback) {
        if (firebaseAuth == null) {
            callback.onError("Firebase não está inicializado");
            return;
        }

        if (firebaseAuth.isSignInWithEmailLink(linkRecebido)) {
            FirebaseUser currentUser = firebaseAuth.getCurrentUser();

            if (currentUser != null) {
                currentUser.reload().addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        if (currentUser.isEmailVerified()) {
                            mainHandler.post(() -> callback.onSuccess("Email verificado com sucesso!"));
                        } else {
                            mainHandler.post(() -> callback.onError("Email ainda não foi verificado."));
                        }
                    } else {
                        Log.e(TAG, "Erro ao recarregar usuário", task.getException());
                        mainHandler.post(() -> callback.onError("Erro ao verificar status do email"));
                    }
                });
            } else {
                callback.onError("Usuário não está logado");
            }
        } else {
            callback.onError("Link de verificação inválido");
        }
    }

    /**
     * Processa a verificação de email de um usuário
     * Corrigido para não usar isSignInWithEmailLink (que é para login por link mágico)
     */
    public void processarLinkVerificacao(RegisterCallback callback) {
        if (firebaseAuth == null) {
            callback.onError("Firebase não está inicializado");
            return;
        }

        FirebaseUser currentUser = firebaseAuth.getCurrentUser();
        if (currentUser != null) {
            currentUser.reload().addOnCompleteListener(task -> {
                if (task.isSuccessful()) {
                    if (currentUser.isEmailVerified()) {
                        Log.d(TAG, "Email verificado com sucesso para: " + currentUser.getEmail());
                        mainHandler.post(() -> callback.onSuccess("Email verificado com sucesso!"));
                    } else {
                        Log.d(TAG, "Email ainda não verificado para: " + currentUser.getEmail());
                        mainHandler.post(() -> callback.onError("Email ainda não foi verificado."));
                    }
                } else {
                    Log.e(TAG, "Erro ao recarregar usuário", task.getException());
                    mainHandler.post(() -> callback.onError("Erro ao verificar status do email"));
                }
            });
        } else {
            callback.onError("Usuário não está logado");
        }
    }

    /**
     * Completa o registro no banco de dados após verificação do email
     * MÉTODO RESTAURADO que estava faltando
     */
    public void completarRegistroNoBanco(UsuarioDTO usuario, DatabaseCallback callback) {
        mainHandler.post(() -> callback.onLoading(true));

        executor.execute(() -> {
            Connection connection = null;
            PreparedStatement preparedStatement = null;

            try {
                // Obtém conexão com o banco
                connection = DatabaseHelper.getConnection();

                // Query SQL usando PreparedStatement para evitar SQL Injection
                String sql = "EXEC Registra_Paciente ?, ?, ?, ?, ?, ?";
                preparedStatement = connection.prepareStatement(sql);

                // Define os parâmetros de forma segura
                preparedStatement.setString(1, usuario.getCpf());
                preparedStatement.setString(2, usuario.getSenha());
                preparedStatement.setString(3, usuario.getEmail());
                preparedStatement.setString(4, usuario.getNome());
                preparedStatement.setString(5, usuario.getNomeSocial() != null ? usuario.getNomeSocial() : usuario.getNome());
                preparedStatement.setString(6, usuario.getTelefone());

                Log.d(TAG, "Executando procedure de cadastro para CPF: " + usuario.getCpf());

                // Executa a procedure
                boolean hasResultSet = preparedStatement.execute();

                if (hasResultSet) {
                    // Se houve um ResultSet, pode ter retornado dados (erro ou sucesso)
                    Log.d(TAG, "Procedure executada com sucesso");
                } else {
                    // Se não houve ResultSet, a procedure foi executada normalmente
                    Log.d(TAG, "Cadastro realizado com sucesso no banco");
                }

                mainHandler.post(() -> {
                    callback.onLoading(false);
                    callback.onSuccess("Cadastro realizado com sucesso!");
                });

            } catch (SQLException e) {
                Log.e(TAG, "Erro SQL ao cadastrar usuário", e);
                String errorMessage = "Erro no cadastro: ";

                if (e.getMessage().contains("UNIQUE")) {
                    errorMessage += "CPF ou email já cadastrado";
                } else if (e.getMessage().contains("CHECK")) {
                    errorMessage += "Dados inválidos";
                } else {
                    errorMessage += e.getMessage();
                }

                final String finalErrorMessage = errorMessage;
                mainHandler.post(() -> {
                    callback.onLoading(false);
                    callback.onError(finalErrorMessage);
                });

            } catch (Exception e) {
                Log.e(TAG, "Erro geral ao cadastrar usuário", e);
                mainHandler.post(() -> {
                    callback.onLoading(false);
                    callback.onError("Erro interno: " + e.getMessage());
                });

            } finally {
                // Fecha recursos
                try {
                    if (preparedStatement != null) preparedStatement.close();
                    if (connection != null) connection.close();
                } catch (SQLException e) {
                    Log.e(TAG, "Erro ao fechar recursos", e);
                }
            }
        });
    }

    // ======================================
    // Utilitários de erros e shutdown
    // ======================================
    private String mapearErroFirebase(Exception exception) {
        if (exception == null) return "Erro desconhecido";
        String errorMessage = exception.getMessage();
        if (errorMessage == null) return "Erro de autenticação";

        if (errorMessage.contains("email-already-in-use")) {
            return "Este email já está cadastrado";
        } else if (errorMessage.contains("invalid-email")) {
            return "Email inválido";
        } else if (errorMessage.contains("weak-password")) {
            return "A senha deve ter pelo menos 6 caracteres";
        } else if (errorMessage.contains("network-request-failed")) {
            return "Erro de conexão. Verifique sua internet";
        } else {
            return "Erro durante o cadastro: " + errorMessage;
        }
    }

    public void shutdown() {
        if (executor != null && !executor.isShutdown()) {
            executor.shutdown();
        }
    }
}