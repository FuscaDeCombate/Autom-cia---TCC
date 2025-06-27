package com.automacia.mobile;

import android.text.Editable;
import android.text.TextWatcher;

import com.google.android.material.textfield.TextInputEditText;

public class TelefoneMaskWatcher implements TextWatcher {
    private final TextInputEditText editText;
    private boolean isUpdating = false;

    public TelefoneMaskWatcher(TextInputEditText editText) {
        this.editText = editText;
    }

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {
        if (isUpdating) return;

        String unmasked = s.toString().replaceAll("[^\\d]", "");
        String masked = applyMask(unmasked);

        isUpdating = true;
        editText.setText(masked);
        editText.setSelection(masked.length());
        isUpdating = false;
    }

    @Override
    public void afterTextChanged(Editable s) {}

    private String applyMask(String phone) {
        if (phone.length() <= 2) {
            return phone;
        } else if (phone.length() <= 6) {
            return String.format("(%s) %s", phone.substring(0, 2), phone.substring(2));
        } else if (phone.length() <= 10) {
            return String.format("(%s) %s-%s",
                    phone.substring(0, 2),
                    phone.substring(2, 6),
                    phone.substring(6));
        } else {
            return String.format("(%s) %s-%s",
                    phone.substring(0, 2),
                    phone.substring(2, 7),
                    phone.substring(7, 11));
        }
    }
}
