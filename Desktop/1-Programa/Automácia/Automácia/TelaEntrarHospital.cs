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
        public TelaEntrarHospital()
        {
            InitializeComponent();
        }

        private void TelaEntrarHospital_Load(object sender, EventArgs e)
        {
            EstiloUtils.arredondarBorda(GroupEntrar, 15);
            EstiloUtils.arredondarBorda(PicBoxLogo, 90);

            EstiloUtils.arredondarBorda(BtnFuncionario, 30);
            EstiloUtils.arredondarBorda(BtnAdministrador, 30);

            FonteUtils.AplicarFonte(LblEntrar, "Inter-Bold", 34f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblMembroHospital, "Inter-Bold", 22f, FontStyle.Regular);
            FonteUtils.AplicarFonte(BtnFuncionario, "Inter-SemiBold", 22f, FontStyle.Regular);
            FonteUtils.AplicarFonte(BtnAdministrador, "Inter-SemiBold", 22f, FontStyle.Regular);
        }

        private void PicBoxLogo_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.desenharBorda(e, sender, 2, 90, Color.Black);
        }

        private void BtnFuncionario_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.desenharBorda(e, sender, 2, 30, Color.Black);
        }

        private void BtnAdministrador_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.desenharBorda(e, sender, 2, 30, Color.Black);
        }

        private void BtnFuncionario_Click(object sender, EventArgs e)
        {
            TelaLoginFuncHospital objTelaLoginFuncHospital = new TelaLoginFuncHospital();
            objTelaLoginFuncHospital.Show();
            this.Hide();
        }

        private void BtnAdministrador_Click(object sender, EventArgs e)
        {
            TelaLoginAdminHospital objTelaLoginAdminHospital = new TelaLoginAdminHospital();
            objTelaLoginAdminHospital.Show();
            this.Hide();
        }

        private void label1_Click(object sender, EventArgs e)
        {
            TelaInicio objTelaInicio = new TelaInicio();
            objTelaInicio.Show();
            this.Hide();
        }
    }
}
