package com.automacia.mobile;

import android.text.Editable;
import android.text.TextWatcher;
import android.widget.EditText;

public class CpfMaskWatcher implements TextWatcher {
    private boolean isUpdating;
    private final EditText editText;
    private String oldText = "";

    public CpfMaskWatcher(EditText editText) {
        this.editText = editText;
    }

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {
        oldText = s.toString();
    }

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {
        if (isUpdating) return;

        String clean = s.toString().replaceAll("[^\\d]", "");

        if (clean.length() > 11) clean = clean.substring(0, 11);

        StringBuilder formatted = new StringBuilder();

        int i = 0;
        while (i < clean.length()) {
            if (i == 3 || i == 6) {
                formatted.append('.');
            } else if (i == 9) {
                formatted.append('-');
            }
            formatted.append(clean.charAt(i));
            i++;
        }

        isUpdating = true;
        editText.setText(formatted.toString());

        editText.setSelection(Math.min(formatted.length(), formatted.length()));
        isUpdating = false;
    }

    @Override
    public void afterTextChanged(Editable s) {
        // nada aqui
    }
}
