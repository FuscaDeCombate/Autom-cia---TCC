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
 * Service responsável pelo envio de emails de confirmação
 * Utiliza JavaMail API para envio via SMTP
 */
public class EmailService {

    private static final String TAG = "EmailService";
    private final ExecutorService executor;
    private final Handler mainHandler;

    // Configurações SMTP (configure conforme seu provedor)
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
     * Envia email de confirmação para o usuário
     * @param nome Nome do usuário
     * @param email Email do destinatário
     * @param callback Callback para retorno do resultado
     */
    public void enviarEmailConfirmacao(String nome, String email, EmailCallback callback) {
        executor.execute(() -> {
            try {
                // Gera código de confirmação (6 dígitos)
                String codigoConfirmacao = gerarCodigoConfirmacao();

                // Prepara o conteúdo do email
                String assunto = "Confirme seu cadastro - Automacia";
                String corpo = criarCorpoEmailConfirmacao(nome, codigoConfirmacao);

                // Envia o email
                boolean sucesso = enviarEmail(email, assunto, corpo);

                mainHandler.post(() -> {
                    if (sucesso) {
                        Log.d(TAG, "Email de confirmação enviado para: " + email);
                        callback.onSuccess();
                    } else {
                        callback.onError("Falha ao enviar email de confirmação");
                    }
                });

            } catch (Exception e) {
                Log.e(TAG, "Erro ao enviar email de confirmação", e);
                mainHandler.post(() -> callback.onError("Erro interno ao enviar email: " + e.getMessage()));
            }
        });
    }

    /**
     * Envia email de boas-vindas após confirmação
     * @param nome Nome do usuário
     * @param email Email do destinatário
     * @param callback Callback para retorno do resultado
     */
    public void enviarEmailBoasVindas(String nome, String email, EmailCallback callback) {
        executor.execute(() -> {
            try {
                String assunto = "Bem-vindo ao Automacia!";
                String corpo = criarCorpoEmailBoasVindas(nome);

                boolean sucesso = enviarEmail(email, assunto, corpo);

                mainHandler.post(() -> {
                    if (sucesso) {
                        Log.d(TAG, "Email de boas-vindas enviado para: " + email);
                        callback.onSuccess();
                    } else {
                        callback.onError("Falha ao enviar email de boas-vindas");
                    }
                });

            } catch (Exception e) {
                Log.e(TAG, "Erro ao enviar email de boas-vindas", e);
                mainHandler.post(() -> callback.onError("Erro interno ao enviar email: " + e.getMessage()));
            }
        });
    }

    /**
     * Metodo principal para envio de email usando JavaMail API
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

            Log.d(TAG, "Email enviado com sucesso via JavaMail para: " + destinatario);
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
     * Gera código de confirmação aleatório de 6 dígitos
     * @return Código de confirmação
     */
    private String gerarCodigoConfirmacao() {
        return String.format("%06d", (int) (Math.random() * 1000000));
    }

    /**
     * Cria o corpo do email de confirmação
     * @param nome Nome do usuário
     * @param codigo Código de confirmação
     * @return HTML do email
     */
    private String criarCorpoEmailConfirmacao(String nome, String codigo) {
        return String.format(
                "<html>" +
                        "<body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>" +
                        "<div style='max-width: 600px; margin: 0 auto; padding: 20px;'>" +
                        "<div style='text-align: center; margin-bottom: 30px;'>" +
                        "<h1 style='color: #2c3e50; margin-bottom: 10px;'>Automacia</h1>" +
                        "<p style='color: #7f8c8d; font-size: 16px;'>Plataforma de Saúde Digital</p>" +
                        "</div>" +
                        "<div style='background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%); " +
                        "padding: 30px; border-radius: 10px; color: white; text-align: center; margin-bottom: 30px;'>" +
                        "<h2 style='margin: 0 0 15px 0;'>Olá, %s!</h2>" +
                        "<p style='margin: 0; font-size: 18px;'>Confirme seu cadastro para começar a usar o Automacia</p>" +
                        "</div>" +
                        "<div style='background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 30px;'>" +
                        "<h3 style='color: #2c3e50; margin-bottom: 15px;'>Seu código de confirmação:</h3>" +
                        "<div style='background: white; padding: 15px; border-radius: 5px; text-align: center; " +
                        "border: 2px dashed #667eea; margin: 15px 0;'>" +
                        "<span style='font-size: 32px; font-weight: bold; color: #667eea; letter-spacing: 5px;'>%s</span>" +
                        "</div>" +
                        "<p style='color: #7f8c8d; font-size: 14px; margin: 10px 0 0 0;'>" +
                        "Digite este código no aplicativo para confirmar seu email</p>" +
                        "</div>" +
                        "<div style='margin-bottom: 30px;'>" +
                        "<h3 style='color: #2c3e50;'>O que você pode fazer com o Automacia:</h3>" +
                        "<ul style='color: #555; padding-left: 20px;'>" +
                        "<li>Gerenciar seus agendamentos médicos</li>" +
                        "<li>Acessar seu histórico de consultas</li>" +
                        "<li>Receber lembretes de medicamentos</li>" +
                        "<li>Consultar resultados de exames</li>" +
                        "</ul>" +
                        "</div>" +
                        "<div style='text-align: center; margin-top: 30px; padding-top: 20px; " +
                        "border-top: 1px solid #eee; color: #7f8c8d; font-size: 14px;'>" +
                        "<p>Se você não fez este cadastro, pode ignorar este email.</p>" +
                        "<p>Este código expira em 15 minutos.</p>" +
                        "<br>" +
                        "<p>© 2025 Automacia - Plataforma de Saúde Digital</p>" +
                        "</div>" +
                        "</div>" +
                        "</body>" +
                        "</html>",
                nome, codigo
        );
    }

    /**
     * Cria o corpo do email de boas-vindas
     * @param nome Nome do usuário
     * @return HTML do email
     */
    private String criarCorpoEmailBoasVindas(String nome) {
        return String.format(
                "<html>" +
                        "<body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>" +
                        "<div style='max-width: 600px; margin: 0 auto; padding: 20px;'>" +
                        "<div style='text-align: center; margin-bottom: 30px;'>" +
                        "<h1 style='color: #2c3e50; margin-bottom: 10px;'>Automacia</h1>" +
                        "<p style='color: #7f8c8d; font-size: 16px;'>Plataforma de Saúde Digital</p>" +
                        "</div>" +
                        "<div style='background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%); " +
                        "padding: 30px; border-radius: 10px; color: white; text-align: center; margin-bottom: 30px;'>" +
                        "<h2 style='margin: 0 0 15px 0;'>Bem-vindo, %s! 🎉</h2>" +
                        "<p style='margin: 0; font-size: 18px;'>Seu cadastro foi confirmado com sucesso!</p>" +
                        "</div>" +
                        "<div style='margin-bottom: 30px;'>" +
                        "<h3 style='color: #2c3e50;'>Primeiros passos:</h3>" +
                        "<ol style='color: #555; padding-left: 20px;'>" +
                        "<li><strong>Complete seu perfil:</strong> Adicione informações médicas importantes</li>" +
                        "<li><strong>Explore o app:</strong> Conheça todas as funcionalidades disponíveis</li>" +
                        "<li><strong>Agende sua primeira consulta:</strong> Encontre profissionais qualificados</li>" +
                        "<li><strong>Configure lembretes:</strong> Nunca mais esqueça seus medicamentos</li>" +
                        "</ol>" +
                        "</div>" +
                        "<div style='background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 30px;'>" +
                        "<h4 style='color: #2c3e50; margin-bottom: 15px;'>💡 Dica importante:</h4>" +
                        "<p style='color: #555; margin: 0;'>" +
                        "Mantenha sempre seus dados atualizados para receber o melhor atendimento. " +
                        "Você pode editar suas informações a qualquer momento no app." +
                        "</p>" +
                        "</div>" +
                        "<div style='text-align: center; margin-bottom: 30px;'>" +
                        "<a href='#' style='display: inline-block; background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%); " +
                        "color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; font-weight: bold;'>" +
                        "Abrir o App Automacia" +
                        "</a>" +
                        "</div>" +
                        "<div style='text-align: center; margin-top: 30px; padding-top: 20px; " +
                        "border-top: 1px solid #eee; color: #7f8c8d; font-size: 14px;'>" +
                        "<p>Precisa de ajuda? Entre em contato conosco:</p>" +
                        "<p>📧 suporte@automacia.com.br | 📱 (11) 9999-9999</p>" +
                        "<br>" +
                        "<p>© 2025 Automacia - Plataforma de Saúde Digital</p>" +
                        "</div>" +
                        "</div>" +
                        "</body>" +
                        "</html>",
                nome
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