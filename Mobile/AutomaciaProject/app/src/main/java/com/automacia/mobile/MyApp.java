package com.automacia.mobile;

import android.app.Application;

import com.automacia.mobile.models.UsuarioDTO;
import com.google.firebase.FirebaseApp;

public class MyApp extends Application {
    private UsuarioDTO usuarioLogado;

    @Override
    public void onCreate(){
        super.onCreate();

        FirebaseApp.initializeApp(this);
    }

    public UsuarioDTO getUsuarioLogado() {
        return usuarioLogado;
    }

    public void setUsuarioLogado(UsuarioDTO usuario) {
        this.usuarioLogado = usuario;
    }
}
