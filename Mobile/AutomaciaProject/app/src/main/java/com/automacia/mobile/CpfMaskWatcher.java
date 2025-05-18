package com.automacia.mobile;

import android.text.Editable;
import android.text.TextWatcher;
import android.widget.EditText;

public class CpfMaskWatcher implements TextWatcher {
    private boolean isUpdating;
    private final EditText editText;

    public CpfMaskWatcher(EditText editText) {
        this.editText = editText;
    }

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {

    }

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {
        if (isUpdating) {
            isUpdating = false;
            return;
        }

        String str = s.toString().replaceAll("[^\\d]", "");
        StringBuilder formatted = new StringBuilder();
        int len = str.length();

        if (len > 0) {
            formatted.append(str.charAt(0));
        }
        if (len > 1) {
            formatted.append(str.charAt(1));
        }
        if (len > 2) {
            formatted.append(str.charAt(2));
            formatted.append(".");
        }
        if (len > 3) {
            formatted.append(str.charAt(3));
        }
        if (len > 4) {
            formatted.append(str.charAt(4));
        }
        if (len > 5) {
            formatted.append(str.charAt(5));
            formatted.append(".");
        }
        if (len > 6) {
            formatted.append(str.charAt(6));
        }
        if (len > 7) {
            formatted.append(str.charAt(7));
        }
        if (len > 8) {
            formatted.append(str.charAt(8));
            formatted.append("-");
        }
        if (len > 9) {
            formatted.append(str.charAt(9));
        }
        if (len > 10) {
            formatted.append(str.charAt(10));
        }

        isUpdating = true;
        editText.setText(formatted.toString());
        editText.setSelection(editText.getText().length());
    }

    @Override
    public void afterTextChanged(Editable s) {

    }
}
