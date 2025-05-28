using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public static class EstiloUtils
{
    [DllImport("Gdi32.dll", EntryPoint = "CreateRoundRectRgn")]
    private static extern IntPtr CreateRoundRectRgn
    (
        int nLeftRect,     // x-coordinate of upper-left corner
        int nTopRect,      // y-coordinate of upper-left corner
        int nRightRect,    // x-coordinate of lower-right corner
        int nBottomRect,   // y-coordinate of lower-right corner
        int nWidthEllipse, // height of ellipse
        int nHeightEllipse // width of ellipse
    );

    public static void arredondarBorda(object sender, int rb)
    {
        Control controle = sender as Control;
        controle.Region = Region.FromHrgn(CreateRoundRectRgn(0, 0, controle.Width, controle.Height, rb, rb));
    }

    public static void desenharBorda(PaintEventArgs e, object sender, int tamanhoBorda, int radiusBorda, Color corBorda)
    {
        int tb = tamanhoBorda;
        int rb = radiusBorda;
        Control controle = sender as Control;

        using (Pen pen = new Pen(corBorda, tamanhoBorda))
        using (GraphicsPath path = new GraphicsPath())
        {
            e.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
            Rectangle rect = new Rectangle(tb - 1, tb - 1, controle.Width - tb * 2, controle.Height - tb * 2);

            path.AddArc(rect.X, rect.Y, rb, rb, 180, 90);
            path.AddArc(rect.Right - rb, rect.Y, rb, rb, 270, 90);
            path.AddArc(rect.Right - rb, rect.Bottom - rb, rb, rb, 0, 90);
            path.AddArc(rect.X, rect.Bottom - rb, rb, rb, 90, 90);
            path.CloseFigure();

            e.Graphics.DrawPath(pen, path);
        }
    }
}

