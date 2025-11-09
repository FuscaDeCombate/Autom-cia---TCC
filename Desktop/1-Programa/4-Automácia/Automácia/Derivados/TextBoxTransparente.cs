using System;
using System.Drawing;
using System.Windows.Forms;
using System.Runtime.InteropServices;

public class RichTextBoxTransparente : RichTextBox
{
    public RichTextBoxTransparente()
    {
        this.SetStyle(ControlStyles.SupportsTransparentBackColor |
                      ControlStyles.OptimizedDoubleBuffer |
                      ControlStyles.AllPaintingInWmPaint, true);

        this.BackColor = Color.Transparent;
        this.BorderStyle = BorderStyle.None;
        this.Multiline = true;
    }

    protected override CreateParams CreateParams
    {
        get
        {
            var cp = base.CreateParams;
            cp.ExStyle |= 0x20; // WS_EX_TRANSPARENT
            return cp;
        }
    }

    protected override void OnPaintBackground(PaintEventArgs e)
    {
        // Não desenha o fundo = transparência simulada
    }

}