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
    public partial class TelaRecuperacaoDeSenha : Form
    {
        Form formularioAnterior;
        private TelaMensagemEnviada objTelaMensagemEnviada;

        public TelaRecuperacaoDeSenha(Form form)
        {
            InitializeComponent();
            this.DoubleBuffered = true;
            formularioAnterior = form;
        }

        private void TelaRecuperacaoDeSenha_Load(object sender, EventArgs e)
        {
            EstiloUtils.ArredondarTudo(PnlRecSenha, 15);

            EstiloUtils.ArredondarTudo(BtnEnviarConfir, 30);

            FonteUtils.AplicarFonte(TxtCPF, "Inter-Regular", 20f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtNovaSenha, "Inter-Regular", 20f, FontStyle.Regular);

            FonteUtils.AplicarFonte(LblInforme, "Inter-Bold", 27.2f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblCPF, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblNovaSenha, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(BtnEnviarConfir, "Inter-Medium", 18f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblVoltar, "Inter-Regular", 22f, FontStyle.Regular);
        }

        private void PnlTxtBoxCPF_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }
        private void PnlTxtBoxNovaSenha_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        private void BtnEnviarConfir_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 30, Color.Black);
        }

        private void TxtCPF_KeyPress(object sender, KeyPressEventArgs e)
        {
            // Permitir apenas números e teclas de controle (como Backspace)
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar))
            {
                e.Handled = true;
            }
        }

        private void BtnEnviarConfir_Click(object sender, EventArgs e)
        {
            //Só de exemplo, sem conexão com o banco ainda
            string cpf = TxtCPF.Text;
            string novaSenha = TxtNovaSenha.Text;
            if (cpf == "12345678910" && novaSenha == "Senha123?")
            {
                TxtCPF.Text = "";
                TxtNovaSenha.Text = "";
                if (objTelaMensagemEnviada == null || objTelaMensagemEnviada.IsDisposed)
                {
                    objTelaMensagemEnviada = new TelaMensagemEnviada(formularioAnterior);
                }
                objTelaMensagemEnviada.Show();
                this.Hide();
            }
            else
            {
                MessageBox.Show("Verifique as credenciais inseridas.", "Usuário não identificado!");
            }
        }

        private void LblVoltar_Click(object sender, EventArgs e)
        {
            TxtCPF.Text = "";
            TxtNovaSenha.Text = "";
            formularioAnterior.Show();
            this.Hide();
        }

        private void TelaRecuperacaoDeSenha_FormClosing(object sender, FormClosingEventArgs e)
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

        private void TelaRecuperacaoDeSenha_FormClosed(object sender, FormClosedEventArgs e)
        {
            Application.Exit();
        }
    }
}
