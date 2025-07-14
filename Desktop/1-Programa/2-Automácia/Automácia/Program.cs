using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Automácia
{
    static class Program
    {

        /// <summary>
        /// Ponto de entrada principal para o aplicativo.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.ThreadException += (sender, args) =>
            {
                MessageBox.Show("Erro: " + args.Exception.Message + "\n\n" + args.Exception.StackTrace, "Erro Global");
            };
            AppDomain.CurrentDomain.UnhandledException += (sender, args) =>
            {
                Exception ex = (Exception)args.ExceptionObject;
                MessageBox.Show("Erro não tratado: " + ex.Message + "\n\n" + ex.StackTrace, "Erro Fatal");
            };

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new TelaInicio());
        }
    }

    public static class Sessao
    {
        public static bool saindo = false;
    }
}
