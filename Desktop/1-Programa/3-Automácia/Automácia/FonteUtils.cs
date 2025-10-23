using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Drawing;
using System.Drawing.Text;
using System.Reflection;
using System.Windows.Forms;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public static class FonteUtils
{
    // 🔒 Guarda as fontes carregadas
    static Dictionary<string, FontFamily> fontesCarregadas = new Dictionary<string, FontFamily>();
    static List<PrivateFontCollection> colecoes = new List<PrivateFontCollection>(); // evita GC

    // 🔗 Importa AddFontMemResourceEx
    [DllImport("gdi32.dll")]
    private static extern IntPtr AddFontMemResourceEx(
        IntPtr pbFont, uint cbFont, IntPtr pdv, [In] ref uint pcFonts);

    public static void AplicarFonte(object sender, string nomeFonteRecurso, float tamanho, FontStyle estilo)
    {
        if (!(sender is Control controle)) return;

        // Se já carregou, reaproveita
        if (!fontesCarregadas.ContainsKey(nomeFonteRecurso))
        {
            string nomeCompleto = "Automácia.Fontes." + nomeFonteRecurso + ".ttf";

            using (Stream fonteStream = Assembly.GetExecutingAssembly().GetManifestResourceStream(nomeCompleto))
            {
                if (fonteStream == null)
                {
                    MessageBox.Show("Fonte não encontrada: " + nomeFonteRecurso);
                    return;
                }

                byte[] dadosFonte = new byte[fonteStream.Length];
                fonteStream.Read(dadosFonte, 0, dadosFonte.Length);
                IntPtr ptrFonte = Marshal.AllocCoTaskMem(dadosFonte.Length);
                Marshal.Copy(dadosFonte, 0, ptrFonte, dadosFonte.Length);

                uint cFonts = 0;
                AddFontMemResourceEx(ptrFonte, (uint)dadosFonte.Length, IntPtr.Zero, ref cFonts);

                PrivateFontCollection novaColecao = new PrivateFontCollection();
                novaColecao.AddMemoryFont(ptrFonte, dadosFonte.Length);
                Marshal.FreeCoTaskMem(ptrFonte);

                fontesCarregadas[nomeFonteRecurso] = novaColecao.Families[0];
                colecoes.Add(novaColecao); // evita ser coletada pelo GC
            }
        }

        Font fonteAplicada = new Font(fontesCarregadas[nomeFonteRecurso], tamanho, estilo);
        controle.Font = fonteAplicada;
    }
}