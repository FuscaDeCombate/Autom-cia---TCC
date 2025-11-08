package com.automacia.mobile.utils;

import android.content.Context;
import android.content.SharedPreferences;

import com.automacia.mobile.models.FuncionarioChatDTO;

/**
 * Helper para gerenciar preferências relacionadas ao chat
 */
public class ChatPreferences {

    private static final String PREFS_NAME = "chat_preferences";
    private static final String KEY_ULTIMO_FUNCIONARIO_ID = "ultimo_funcionario_id";
    private static final String KEY_ULTIMO_FUNCIONARIO_NOME = "ultimo_funcionario_nome";
    private static final String KEY_ULTIMO_FUNCIONARIO_TIPO = "ultimo_funcionario_tipo";
    private static final String KEY_ULTIMO_FUNCIONARIO_HOSPITAL = "ultimo_funcionario_hospital";
    private static final String KEY_ULTIMO_FUNCIONARIO_ATIVO = "ultimo_funcionario_ativo";

    private final SharedPreferences prefs;

    public ChatPreferences(Context context) {
        this.prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
    }

    /**
     * Salva o último funcionário com quem o usuário conversou
     */
    public void salvarUltimoFuncionario(FuncionarioChatDTO funcionario) {
        if (funcionario == null) {
            limparUltimoFuncionario();
            return;
        }

        SharedPreferences.Editor editor = prefs.edit();
        editor.putString(KEY_ULTIMO_FUNCIONARIO_ID, funcionario.getFuncionarioRec());
        editor.putString(KEY_ULTIMO_FUNCIONARIO_NOME, funcionario.getNomeFuncionario());
        editor.putString(KEY_ULTIMO_FUNCIONARIO_TIPO, funcionario.getTipoFuncionario());
        editor.putString(KEY_ULTIMO_FUNCIONARIO_HOSPITAL, funcionario.getHospital());
        editor.putBoolean(KEY_ULTIMO_FUNCIONARIO_ATIVO, funcionario.isAtivo());
        editor.apply();
    }

    /**
     * Recupera o último funcionário salvo
     * @return FuncionarioChatDTO ou null se não houver
     */
    public FuncionarioChatDTO getUltimoFuncionario() {
        String funcionarioId = prefs.getString(KEY_ULTIMO_FUNCIONARIO_ID, null);

        if (funcionarioId == null || funcionarioId.isEmpty()) {
            return null;
        }

        FuncionarioChatDTO funcionario = new FuncionarioChatDTO();
        funcionario.setFuncionarioRec(funcionarioId);
        funcionario.setNomeFuncionario(prefs.getString(KEY_ULTIMO_FUNCIONARIO_NOME, ""));
        funcionario.setTipoFuncionario(prefs.getString(KEY_ULTIMO_FUNCIONARIO_TIPO, ""));
        funcionario.setHospital(prefs.getString(KEY_ULTIMO_FUNCIONARIO_HOSPITAL, ""));
        funcionario.setAtivo(prefs.getBoolean(KEY_ULTIMO_FUNCIONARIO_ATIVO, true));

        return funcionario;
    }

    /**
     * Verifica se há um funcionário salvo
     */
    public boolean temUltimoFuncionario() {
        String funcionarioId = prefs.getString(KEY_ULTIMO_FUNCIONARIO_ID, null);
        return funcionarioId != null && !funcionarioId.isEmpty();
    }

    /**
     * Remove o último funcionário salvo
     */
    public void limparUltimoFuncionario() {
        SharedPreferences.Editor editor = prefs.edit();
        editor.remove(KEY_ULTIMO_FUNCIONARIO_ID);
        editor.remove(KEY_ULTIMO_FUNCIONARIO_NOME);
        editor.remove(KEY_ULTIMO_FUNCIONARIO_TIPO);
        editor.remove(KEY_ULTIMO_FUNCIONARIO_HOSPITAL);
        editor.remove(KEY_ULTIMO_FUNCIONARIO_ATIVO);
        editor.apply();
    }

    /**
     * Obtém apenas o ID do último funcionário
     */
    public String getUltimoFuncionarioId() {
        return prefs.getString(KEY_ULTIMO_FUNCIONARIO_ID, null);
    }

    /**
     * Obtém apenas o nome do último funcionário
     */
    public String getUltimoFuncionarioNome() {
        return prefs.getString(KEY_ULTIMO_FUNCIONARIO_NOME, null);
    }
}