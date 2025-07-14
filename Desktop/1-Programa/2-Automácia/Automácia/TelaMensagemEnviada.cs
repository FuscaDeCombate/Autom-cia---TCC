using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Automácia
{
    public partial class TelaMensagemEnviada : Form
    {
        Form formularioAnterior;

        public TelaMensagemEnviada(Form form)
        {
            InitializeComponent();
            this.DoubleBuffered = true;
            formularioAnterior = form;
        }

        private void TelaMensagemEnviada_Load(object sender, EventArgs e)
        {
            EstiloUtils.ArredondarTudo(PnlMensagemEnviada, 15);

            FonteUtils.AplicarFonte(LblMensagem, "Inter-Bold", 18.1f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblEmail, "Inter-SemiBold", 18.1f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblConfirmar, "Inter-Medium", 18.1f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblVoltar, "Inter-Regular", 22f, FontStyle.Regular);
        }

        private void LblVoltar_Click(object sender, EventArgs e)
        {
            formularioAnterior.Show();
            this.Hide();
        }

        private void TelaMensagemEnviada_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (!Sessao.saindo)
            {
                var confirmar = MessageBox.Show("Deseja realmente sair?", "Sair", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

                if (confirmar == DialogResult.Yes)
                {
                    Sessao.saindo = true; // marca como já confirmado
                    Application.Exit();   // fecha tudo
                }
                else
                {
                    e.Cancel = true; // cancela o fechamento
                }
            }
        }

        private void TelaMensagemEnviada_FormClosed(object sender, FormClosedEventArgs e)
        {
            Application.Exit();
        }
    }
}
