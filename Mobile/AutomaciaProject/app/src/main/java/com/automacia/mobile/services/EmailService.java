package com.automacia.mobile.services;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

/**
 * Service responsável pelo envio de emails de código de recuperação de senha
 */
public class EmailService {

    private static final String TAG = "EmailService";
    private final ExecutorService executor;
    private final Handler mainHandler;

    // Configurações SMTP
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String EMAIL_FROM = "tomazturbando878@gmail.com";
    private static final String EMAIL_PASSWORD = "lozoiuiopynbnoob";
    private static final String EMAIL_FROM_NAME = "Automacia";

    public EmailService() {
        executor = Executors.newSingleThreadExecutor();
        mainHandler = new Handler(Looper.getMainLooper());
    }

    /**
     * Interface para callback do envio de email
     */
    public interface EmailCallback {
        void onSuccess();
        void onError(String error);
    }

    /**
     * Envia código de recuperação de senha por email
     * @param email Email do destinatário
     * @param code Código de verificação de 6 dígitos
     * @param callback Callback para retorno do resultado
     */
    public void enviarCodigoRecuperacao(String email, String code, EmailCallback callback) {
        executor.execute(() -> {
            try {
                String assunto = "Código de Recuperação de Senha - Automacia";
                String corpo = criarCorpoEmailCodigoRecuperacao(code);

                boolean sucesso = enviarEmail(email, assunto, corpo);

                mainHandler.post(() -> {
                    if (sucesso) {
                        Log.d(TAG, "Código de recuperação enviado para: " + email);
                        if (callback != null) callback.onSuccess();
                    } else {
                        Log.w(TAG, "Falha ao enviar código de recuperação para: " + email);
                        if (callback != null) callback.onError("Falha ao enviar código de recuperação");
                    }
                });

            } catch (Exception e) {
                Log.e(TAG, "Erro ao enviar código de recuperação", e);
                mainHandler.post(() -> {
                    if (callback != null) callback.onError("Erro interno ao enviar email: " + e.getMessage());
                });
            }
        });
    }

    /**
     * Método principal para envio de email usando JavaMail API
     * @param destinatario Email do destinatário
     * @param assunto Assunto do email
     * @param corpo Corpo do email (HTML)
     * @return true se enviado com sucesso, false caso contrário
     */
    private boolean enviarEmail(String destinatario, String assunto, String corpo) {
        try {
            // Configurações do servidor SMTP
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.ssl.trust", SMTP_HOST);

            // Autenticação
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(EMAIL_FROM, EMAIL_PASSWORD);
                }
            });

            // Criar mensagem
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(EMAIL_FROM, EMAIL_FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(destinatario));
            message.setSubject(assunto);
            message.setContent(corpo, "text/html; charset=utf-8");

            // Enviar
            Transport.send(message);

            Log.d(TAG, "Email enviado com sucesso para: " + destinatario);
            return true;

        } catch (MessagingException e) {
            Log.e(TAG, "Erro de messaging ao enviar email", e);
            return false;
        } catch (Exception e) {
            Log.e(TAG, "Erro geral ao enviar email", e);
            return false;
        }
    }

    /**
     * Cria o corpo do email de código de recuperação
     * @param code Código de verificação de 6 dígitos
     * @return HTML do email
     */
    private String criarCorpoEmailCodigoRecuperacao(String code) {
        return String.format(
                "<html>" +
                        "<body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0;'>" +
                        "<div style='max-width: 600px; margin: 0 auto; padding: 0;'>" +

                        "<!-- Header -->" +
                        "<div style='background: linear-gradient(135deg, #001A6E 0%%, #001447 100%%); " +
                        "padding: 40px 30px; text-align: center; color: white;'>" +
                        "<h1 style='color: white; margin: 0 0 10px 0; font-size: 32px; font-weight: bold;'>Automacia</h1>" +
                        "<p style='color: #E8EFFF; font-size: 16px; margin: 0; opacity: 0.9;'>Plataforma de Saúde Digital</p>" +
                        "</div>" +

                        "<!-- Main Content -->" +
                        "<div style='background: white; padding: 40px 30px;'>" +

                        "<!-- Icon & Title -->" +
                        "<div style='text-align: center; margin-bottom: 30px;'>" +
                        "<div style='background: #E8EFFF; width: 80px; height: 80px; border-radius: 50%%; " +
                        "margin: 0 auto 20px; display: flex; align-items: center; justify-content: center;'>" +
                        "<span style='font-size: 36px;'>🔐</span>" +
                        "</div>" +
                        "<h2 style='color: #001447; margin: 0 0 10px 0; font-size: 28px;'>Código de Recuperação</h2>" +
                        "<p style='color: #666666; margin: 0; font-size: 16px;'>" +
                        "Use o código abaixo para recuperar sua senha" +
                        "</p>" +
                        "</div>" +

                        "<!-- Verification Code -->" +
                        "<div style='background: linear-gradient(135deg, #001A6E 0%%, #001447 100%%); " +
                        "padding: 30px; border-radius: 15px; text-align: center; margin-bottom: 30px; " +
                        "box-shadow: 0 8px 32px rgba(0, 26, 110, 0.2);'>" +
                        "<p style='color: #E8EFFF; margin: 0 0 15px 0; font-size: 16px; opacity: 0.9;'>" +
                        "Seu código de verificação é:" +
                        "</p>" +
                        "<div style='background: white; padding: 20px; border-radius: 10px; margin: 0 auto; " +
                        "display: inline-block; min-width: 200px;'>" +
                        "<span style='font-size: 36px; font-weight: bold; color: #001447; letter-spacing: 8px;'>%s</span>" +
                        "</div>" +
                        "</div>" +

                        "<!-- Instructions -->" +
                        "<div style='background: #E8EFFF; padding: 25px; border-radius: 10px; margin-bottom: 30px;'>" +
                        "<h3 style='color: #001447; margin: 0 0 15px 0; font-size: 18px;'>📱 Como usar:</h3>" +
                        "<ol style='color: #666666; margin: 0; padding-left: 20px;'>" +
                        "<li style='margin-bottom: 8px;'>Digite o código na tela de verificação</li>" +
                        "<li style='margin-bottom: 8px;'>Crie uma nova senha segura</li>" +
                        "<li>Faça login com sua nova senha</li>" +
                        "</ol>" +
                        "</div>" +

                        "<!-- Security Warning -->" +
                        "<div style='background: #FFEBEA; border: 1px solid #FF2514; padding: 20px; " +
                        "border-radius: 10px; margin-bottom: 30px;'>" +
                        "<h4 style='color: #CC1D10; margin: 0 0 10px 0; font-size: 16px;'>⚠️ Importante:</h4>" +
                        "<ul style='color: #CC1D10; margin: 0; padding-left: 20px; font-size: 14px;'>" +
                        "<li style='margin-bottom: 5px;'>Este código expira em 15 minutos</li>" +
                        "<li style='margin-bottom: 5px;'>Não compartilhe este código com ninguém</li>" +
                        "<li>Se você não solicitou esta recuperação, ignore este email</li>" +
                        "</ul>" +
                        "</div>" +

                        "<!-- Support Info -->" +
                        "<div style='background: #f8f9fa; padding: 20px; border-radius: 10px; " +
                        "text-align: center; margin-bottom: 20px;'>" +
                        "<h4 style='color: #001447; margin-bottom: 15px; font-size: 16px;'>💬 Precisa de ajuda?</h4>" +
                        "<p style='color: #666666; margin-bottom: 10px; font-size: 14px;'>" +
                        "Nossa equipe está sempre pronta para ajudar:" +
                        "</p>" +
                        "<p style='color: #001A6E; font-weight: bold; margin: 5px 0; font-size: 14px;'>📧 suporte@automacia.com.br</p>" +
                        "<p style='color: #001A6E; font-weight: bold; margin: 5px 0; font-size: 14px;'>📱 (11) 9999-9999</p>" +
                        "</div>" +

                        "</div>" +

                        "<!-- Footer -->" +
                        "<div style='background: #1F1F1F; padding: 25px 30px; text-align: center;'>" +
                        "<p style='color: #757575; margin: 5px 0; font-size: 12px;'>© 2025 Automacia - Plataforma de Saúde Digital</p>" +
                        "<p style='color: #757575; margin: 5px 0; font-size: 12px;'>Cuidando da sua saúde com tecnologia e segurança</p>" +
                        "</div>" +

                        "</div>" +
                        "</body>" +
                        "</html>",
                code
        );
    }

    /**
     * Libera recursos do service
     */
    public void shutdown() {
        if (executor != null && !executor.isShutdown()) {
            executor.shutdown();
        }
    }
}