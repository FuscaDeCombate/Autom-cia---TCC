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
    public partial class TelaLoginAdminHospital : Form
    {
        Form formularioAnterior;
        private TelaFuncoesAdminHospital objTelaFuncoesAdminHospital;
        private TelaRecuperacaoDeSenha objTelaRecuperacaoDeSenha;

        public TelaLoginAdminHospital(Form form)
        {
            InitializeComponent();
            this.DoubleBuffered = true;
            formularioAnterior = form;
        }

        private void TelaLoginFuncHospital_Load(object sender, EventArgs e)
        {
            EstiloUtils.ArredondarTudo(PnlLogin, 15);

            EstiloUtils.ArredondarTudo(BtnEntrar, 30);

            FonteUtils.AplicarFonte(TxtCPF, "Inter-Regular", 20f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtSenha, "Inter-Regular", 20f, FontStyle.Regular);

            FonteUtils.AplicarFonte(LblInforme, "Inter-Bold", 36f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblCPF, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblSenha, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(BtnEntrar, "Inter-Medium", 22f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblEsqueceu, "Inter-SemiBold", 13.3f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblVoltar, "Inter-Regular", 22f, FontStyle.Regular);
        }

        private void PnlTxtBoxCPF_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }
        private void PnlTxtBoxSenha_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        private void BtnEntrar_Paint(object sender, PaintEventArgs e)
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

        private void BtnEntrar_Click(object sender, EventArgs e)
        {
            //Só de exemplo, sem conexão com o banco ainda
            string cpf = TxtCPF.Text;
            string senha = TxtSenha.Text;
            if (cpf == "12345678910" && senha == "Senha123?")
            {
                TxtCPF.Text = "";
                TxtSenha.Text = "";
                if (objTelaFuncoesAdminHospital == null || objTelaFuncoesAdminHospital.IsDisposed)
                {
                    objTelaFuncoesAdminHospital = new TelaFuncoesAdminHospital();
                }
                objTelaFuncoesAdminHospital.Show();
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
            TxtSenha.Text = "";
            formularioAnterior.Show();
            this.Hide();
        }

        private void LblEsqueceu_Click(object sender, EventArgs e)
        {
            TxtCPF.Text = "";
            TxtSenha.Text = "";
            if (objTelaRecuperacaoDeSenha == null || objTelaRecuperacaoDeSenha.IsDisposed)
            {
                objTelaRecuperacaoDeSenha = new TelaRecuperacaoDeSenha(this);
            }
            objTelaRecuperacaoDeSenha.Show();
            this.Hide();
        }

        private void TelaLoginAdminHospital_FormClosing(object sender, FormClosingEventArgs e)
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

        private void TelaLoginAdminHospital_FormClosed(object sender, FormClosedEventArgs e)
        {
            Application.Exit();
        }
    }
}

