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
    public partial class TelaEntrarHospital : Form
    {
        Form formularioAnterior;
        private TelaLoginFuncHospital objTelaLoginFuncHospital;
        private TelaLoginAdminHospital objTelaLoginAdminHospital;

        public TelaEntrarHospital(Form form)
        {
            InitializeComponent();
            this.DoubleBuffered = true; 
            formularioAnterior = form;
        }

        private void TelaEntrarHospital_Load(object sender, EventArgs e)
        {
            EstiloUtils.ArredondarTudo(PnlEntrar, 15);
            EstiloUtils.ArredondarTudo(PicBoxLogo, 90);

            EstiloUtils.ArredondarTudo(BtnFuncionario, 30);
            EstiloUtils.ArredondarTudo(BtnAdministrador, 30);

            FonteUtils.AplicarFonte(LblEntrar, "Inter-Bold", 36f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblMembroHospital, "Inter-SemiBold", 22.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(BtnFuncionario, "Inter-Medium", 22f, FontStyle.Regular);
            FonteUtils.AplicarFonte(BtnAdministrador, "Inter-Medium", 22f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblVoltar, "Inter-Regular", 22f, FontStyle.Regular);
        }

        private void PicBoxLogo_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 86, Color.Black);
        }

        private void BtnFuncionario_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 30, Color.Black);
        }

        private void BtnAdministrador_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 30, Color.Black);
        }

        private void BtnFuncionario_Click(object sender, EventArgs e)
        {
            if (objTelaLoginFuncHospital == null || objTelaLoginFuncHospital.IsDisposed)
            {
                objTelaLoginFuncHospital = new TelaLoginFuncHospital(this);
            }
            objTelaLoginFuncHospital.Show();
            this.Hide();
        }

        private void BtnAdministrador_Click(object sender, EventArgs e)
        {
            if (objTelaLoginAdminHospital == null || objTelaLoginAdminHospital.IsDisposed)
            {
                objTelaLoginAdminHospital = new TelaLoginAdminHospital(this);
            }
            objTelaLoginAdminHospital.Show();
            this.Hide();
        }

        private void LblVoltar_Click(object sender, EventArgs e)
        {
            formularioAnterior.Show();
            this.Hide();
        }

        private void TelaEntrarHospital_FormClosing(object sender, FormClosingEventArgs e)
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

        private void TelaEntrarHospital_FormClosed(object sender, FormClosedEventArgs e)
        {
            Application.Exit();
        }
    }
}
