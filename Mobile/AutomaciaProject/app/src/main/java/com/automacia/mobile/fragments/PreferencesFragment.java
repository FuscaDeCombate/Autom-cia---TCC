package com.automacia.mobile.fragments;

import android.content.Intent;
import android.os.Bundle;

import androidx.fragment.app.Fragment;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.automacia.mobile.AboutPage;
import com.automacia.mobile.R;

public class PreferencesFragment extends Fragment {

    public PreferencesFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_preferences, container, false);

        LinearLayout btnAboutApp = view.findViewById(R.id.btnAboutApp);
        btnAboutApp.setOnClickListener(v -> {
            Intent intent = new Intent(getActivity(), AboutPage.class);
            startActivity(intent);
        });

        return view;
    }
}