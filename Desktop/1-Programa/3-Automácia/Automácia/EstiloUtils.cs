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
        int nLeftRect,
        int nTopRect,
        int nRightRect,
        int nBottomRect,
        int nWidthEllipse,
        int nHeightEllipse 
    );

    public static void ArredondarTudo(Control controle, int radius)
    {
        controle.Region = Region.FromHrgn(CreateRoundRectRgn(0, 0,controle.Width,controle.Height,radius, radius));
    }

    public static void ArredondarCantos(Control controle, int radius, bool supEsq, bool supDir, bool infDir, bool infEsq)
    {
        GraphicsPath path = new GraphicsPath();
        Rectangle rect = new Rectangle(-1, -1, controle.Width+1, controle.Height+1);

        // Top Left
        if (supEsq)
        {
            path.AddArc(rect.X, rect.Y, radius, radius, 180, 90);
        }
        else
        {
            path.AddLine(rect.X, rect.Y, rect.X + radius / 2, rect.Y);
        }

        // Top Right
        if (supDir)
        {
            path.AddArc(rect.Right - radius, rect.Y, radius, radius, 270, 90);
        }
        else
        {
            path.AddLine(rect.Right - radius / 2, rect.Y, rect.Right, rect.Y);
        }

        // Bottom Right
        if (infDir)
        {
            path.AddArc(rect.Right - radius, rect.Bottom - radius, radius, radius, 0, 90);
        }
        else
        {
            path.AddLine(rect.Right, rect.Bottom - radius / 2, rect.Right, rect.Bottom);
        }

        // Bottom Left
        if (infEsq)
        {
            path.AddArc(rect.X, rect.Bottom - radius, radius, radius, 90, 90);
        }
        else
        {
            path.AddLine(rect.X, rect.Bottom, rect.X, rect.Bottom - radius / 2);
        }

        path.CloseFigure();
        controle.Region = new Region(path); // <- aplica direto no controle
    }

    public static void DesenharBorda(PaintEventArgs e, object sender, int espessura, bool topo, bool baixo, bool esquerda, bool direita, Color cor)
    {
        Control controle = sender as Control;
        using (Pen pen = new Pen(cor, espessura))
        {
            pen.Alignment = System.Drawing.Drawing2D.PenAlignment.Inset;

            int metade = espessura / 2;
            Graphics g = e.Graphics;

            if (topo)
                g.DrawLine(pen, metade*2-1, metade, controle.Width-metade*2, metade);

            if (esquerda)
                g.DrawLine(pen, metade, 0, metade, controle.Height);

            if (direita)
                g.DrawLine(pen, controle.Width - metade, 0, controle.Width - metade, controle.Height);

            if (baixo)
                g.DrawLine(pen, 0, controle.Height - metade, controle.Width, controle.Height - metade);
        }
    }

    public static void DesenharBordaTodaArredondada(PaintEventArgs e,  object sender, int espessura, int radius, Color cor)
    {
        Control controle = sender as Control;

        using (Pen pen = new Pen(cor, espessura))
        using (GraphicsPath path = new GraphicsPath())
        {
            e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;

            int metade = espessura / 2;

            Rectangle rect = new Rectangle(metade, metade, controle.Width - metade * 2 - 2, controle.Height - metade * 2 - 2);

            path.AddArc(rect.X, rect.Y, radius, radius, 180, 90); // Top Left
            path.AddArc(rect.Right - radius, rect.Y, radius, radius, 270, 90); // Top Right
            path.AddArc(rect.Right - radius, rect.Bottom - radius, radius, radius, 0, 90); // Bottom Right
            path.AddArc(rect.X, rect.Bottom - radius, radius, radius, 90, 90); // Bottom Left

            path.CloseFigure();
            e.Graphics.DrawPath(pen, path);
        }
    }

    public static void DesenharBordaArredondada(PaintEventArgs e, object sender, int espessura, int radius, bool supEsq, bool supDir, bool infDir, bool infEsq, Color cor)
    {
        Control controle = sender as Control;

        using (Pen pen = new Pen(cor, espessura))
        using (GraphicsPath path = new GraphicsPath())
        {
            e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;

            int metade = espessura / 2;
            Rectangle rect = new Rectangle(metade-1, metade-1, controle.Width - espessura+1, controle.Height - espessura+1);

            // Top Left
            if (supEsq)
            {
                path.AddArc(rect.X, rect.Y, radius, radius, 180, 90);
            }
            else
            {
                path.AddLine(rect.X, rect.Y, rect.X + radius / 2, rect.Y);
            }

            // Top Right
            if (supDir)
            {
                path.AddArc(rect.Right - radius, rect.Y, radius, radius, 270, 90);
            }
            else
            {
                path.AddLine(rect.Right - radius / 2, rect.Y, rect.Right, rect.Y);
            }

            // Bottom Right
            if (infDir)
            {
                path.AddArc(rect.Right - radius, rect.Bottom - radius, radius, radius, 0, 90);
            }
            else
            {
                path.AddLine(rect.Right, rect.Bottom - radius / 2, rect.Right, rect.Bottom);
            }

            // Bottom Left
            if (infEsq)
            {
                path.AddArc(rect.X, rect.Bottom - radius, radius, radius, 90, 90);
            }
            else
            {
                path.AddLine(rect.X, rect.Bottom, rect.X, rect.Bottom - radius / 2);
            }

            path.CloseFigure();
            e.Graphics.DrawPath(pen, path);
        }
    }

    public static void DesenharBordaSemBase(PaintEventArgs e, object sender, int espessura, int radius, Color cor, bool arcoEsquerda)
    {
        Control controle = sender as Control;
        using (Pen pen = new Pen(cor, espessura))
        {
            e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;

            int metade = espessura / 2;

            GraphicsPath path = new GraphicsPath();
            if (arcoEsquerda)
            {
                path.AddLine(metade - 1, controle.Height, metade - 1, metade + radius / 2); // Lateral esquerda
                path.AddArc(metade - 1, metade - 1, radius, radius, 180, 90); // Arco canto superior esquerdo
                path.AddLine(metade + radius / 2, metade - 1, controle.Width - metade, metade - 1); // Linha do topo até canto superior direito
                path.AddLine(controle.Width - metade, metade, controle.Width - metade, controle.Height); // Lateral direita

            }
            else
            {
                path.AddLine(metade - 1, controle.Height, metade - 1, metade - 1); // Lateral esquerda
                path.AddLine(metade - 1, metade - 1, controle.Width - metade - radius / 2, metade - 1); // Linha do topo até antes do arco
                path.AddArc(controle.Width - metade - radius, metade - 1, radius, radius, 270, 90); // Arco canto superior direito
                path.AddLine(controle.Width - metade, metade + radius / 2, controle.Width - metade, controle.Height); // Lateral direita
            }
            e.Graphics.DrawPath(pen, path);
        }
    }
}

