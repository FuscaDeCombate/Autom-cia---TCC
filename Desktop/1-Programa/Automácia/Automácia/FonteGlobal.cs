using System;
using System.IO;
using System.Drawing;
using System.Drawing.Text;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Windows.Forms;


public static class FonteGlobal
{
    private static PrivateFontCollection _fontes = new PrivateFontCollection();
    private static bool _carregada = false;

    public static Font FontePadrao { get; private set; }

    public static void InicializarFonte(float tamanho = 28f)
    {
        if (_carregada) return;

        // Altere o nome abaixo conforme o nome do recurso da fonte
        string nomeRecurso = "Automácia.Fontes.Inter-Bold.ttf";

        using (Stream fontStream = Assembly.GetExecutingAssembly().GetManifestResourceStream(nomeRecurso))
        {
            if (fontStream == null)
            {
                MessageBox.Show("Não foi possível carregar a fonte incorporada.");
                return;
            }

            byte[] fontData = new byte[fontStream.Length];
            fontStream.Read(fontData, 0, fontData.Length);
            IntPtr fontPtr = Marshal.AllocCoTaskMem(fontData.Length);
            Marshal.Copy(fontData, 0, fontPtr, fontData.Length);
            _fontes.AddMemoryFont(fontPtr, fontData.Length);
            Marshal.FreeCoTaskMem(fontPtr);

            FontePadrao = new Font(_fontes.Families[0], tamanho);
            _carregada = true;
        }
    }

    public static void AplicarFonteGlobal(Control.ControlCollection controles)
    {
        foreach (Control ctrl in controles)
        {
            ctrl.Font = FontePadrao;

            if (ctrl.HasChildren)
            {
                AplicarFonteGlobal(ctrl.Controls);
            }
        }
    }
}
