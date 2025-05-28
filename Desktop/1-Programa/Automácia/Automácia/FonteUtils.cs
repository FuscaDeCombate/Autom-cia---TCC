using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Drawing;
using System.Drawing.Text;
using System.Reflection;
using System.Windows.Forms;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public static class FonteUtils
{

    static PrivateFontCollection fonteColecao = new PrivateFontCollection();

    public static void AplicarFonte(object sender, string nomeFonteRecurso, float tamanho, FontStyle peso)
    {
        Control controle = sender as Control;

        string nomeRecurso = "Automácia.Fontes." + nomeFonteRecurso + ".ttf";

        using (Stream fonteStream = Assembly.GetExecutingAssembly().GetManifestResourceStream(nomeRecurso))
        {
            if (fonteStream == null)
            {
                MessageBox.Show("Recurso de fonte não encontrado:\n" + nomeFonteRecurso);
                return;
            }

            byte[] fonteData = new byte[fonteStream.Length];
            fonteStream.Read(fonteData, 0, fonteData.Length);
            IntPtr fontPtr = Marshal.AllocCoTaskMem(fonteData.Length);
            Marshal.Copy(fonteData, 0, fontPtr, fonteData.Length);
            fonteColecao.AddMemoryFont(fontPtr, fonteData.Length);
            Marshal.FreeCoTaskMem(fontPtr);

            Font novaFonte = new Font(fonteColecao.Families[0], tamanho, peso);
            controle.Font = novaFonte;
        }
    }
}



