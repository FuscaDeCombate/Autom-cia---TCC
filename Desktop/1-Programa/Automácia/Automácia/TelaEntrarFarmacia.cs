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
    public partial class TelaEntrarFarmacia : Form
    {
        public TelaEntrarFarmacia()
        {
            InitializeComponent();
        }

        private void TelaEntrarFarmacia_Load(object sender, EventArgs e)
        {
            EstiloUtils.arredondarBorda(GroupEntrar, 15);
            EstiloUtils.arredondarBorda(PicBoxLogo, 90);

            EstiloUtils.arredondarBorda(BtnFuncionario, 30);
            EstiloUtils.arredondarBorda(BtnAdministrador, 30);

            FonteUtils.AplicarFonte(LblEntrar, "Inter-Bold", 34f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblMembroFarmacia, "Inter-Bold", 22f, FontStyle.Regular);
            FonteUtils.AplicarFonte(BtnFuncionario, "Inter-SemiBold", 22f, FontStyle.Regular);
            FonteUtils.AplicarFonte(BtnAdministrador, "Inter-SemiBold", 22f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblVoltar, "Inter-Regular", 22f, FontStyle.Regular);
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
            TelaLoginFuncFarmacia objTelaLoginFuncFarmacia = new TelaLoginFuncFarmacia();
            objTelaLoginFuncFarmacia.Show();
            this.Hide();
        }

        private void BtnAdministrador_Click(object sender, EventArgs e)
        {
            TelaLoginAdminFarmacia objTelaLoginAdminFarmacia = new TelaLoginAdminFarmacia();
            objTelaLoginAdminFarmacia.Show();
            this.Hide();
        }

        private void LblSair_Click(object sender, EventArgs e)
        {
            TelaInicio objTelaInicio = new TelaInicio();
            objTelaInicio.Show();
            this.Hide();
        }
    }
}
