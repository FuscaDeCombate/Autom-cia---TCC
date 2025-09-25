package com.automacia.mobile;

import android.app.Application;

import com.automacia.mobile.models.UsuarioDTO;

public class MyApp extends Application {
    private UsuarioDTO usuarioLogado;

    public UsuarioDTO getUsuarioLogado() {
        return usuarioLogado;
    }

    public void setUsuarioLogado(UsuarioDTO usuario) {
        this.usuarioLogado = usuario;
    }
}
