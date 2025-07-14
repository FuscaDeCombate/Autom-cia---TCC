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

namespace Automácia
{
    public partial class TelaInicio : Form
    {
        private TelaEntrarHospital objTelaEntrarHospital;
        private TelaEntrarFarmacia objTelaEntrarFarmacia;

        public TelaInicio()
        {
            InitializeComponent();
            this.DoubleBuffered = true;
        }

        private void TelaInicio_Load(object sender, EventArgs e)
        {
            EstiloUtils.ArredondarTudo(PnlEntrar, 15);
            EstiloUtils.ArredondarTudo(PicBoxLogo, 90);

            EstiloUtils.ArredondarTudo(BtnHospitalEntrar, 30);
            EstiloUtils.ArredondarTudo(BtnFarmaciaEntrar, 30);

            FonteUtils.AplicarFonte(LblEntrar, "Inter-Bold", 36f, FontStyle.Bold);
            FonteUtils.AplicarFonte(BtnHospitalEntrar, "Inter-Medium", 22f, FontStyle.Regular);
            FonteUtils.AplicarFonte(BtnFarmaciaEntrar, "Inter-Medium", 22f, FontStyle.Regular);
        }

        private void PicBoxLogo_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 86, Color.Black);
        }

        private void BtnHospitalEntrar_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 30, Color.Black);
        }

        private void BtnFarmaciaEntrar_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 30, Color.Black);
        }

        private void BtnHospitalEntrar_Click(object sender, EventArgs e)
        {
            if (objTelaEntrarHospital == null || objTelaEntrarHospital.IsDisposed)
            {
                objTelaEntrarHospital = new TelaEntrarHospital(this);
            }
            objTelaEntrarHospital.Show();
            this.Hide();
        }

        private void BtnFarmaciaEntrar_Click(object sender, EventArgs e)
        {
            if (objTelaEntrarFarmacia == null || objTelaEntrarFarmacia.IsDisposed)
            {
                objTelaEntrarFarmacia = new TelaEntrarFarmacia(this);
            }
            objTelaEntrarFarmacia.Show();
            this.Hide();
        }

        private void TelaInicio_FormClosing(object sender, FormClosingEventArgs e)
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

        private void TelaInicio_FormClosed(object sender, FormClosedEventArgs e)
        {
            Application.Exit();
        }
    }
}