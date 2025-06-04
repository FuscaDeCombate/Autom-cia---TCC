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
    public partial class TelaLoginFuncHospital : Form
    {
        public TelaLoginFuncHospital()
        {
            InitializeComponent();
        }

        private void TelaLoginFuncHospital_Load(object sender, EventArgs e)
        {
            EstiloUtils.arredondarBorda(GroupEntrar, 15);

            EstiloUtils.arredondarBorda(BtnEntrar, 30);

            FonteUtils.AplicarFonte(LblInforme, "Inter-Bold", 34f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblCPF, "Inter-Bold", 15f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblSenha, "Inter-SemiBold", 15f, FontStyle.Bold);
            FonteUtils.AplicarFonte(BtnEntrar, "Inter-SemiBold", 22f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblEsqueceu, "Inter-SemiBold", 15f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblVoltar, "Inter-Regular", 22f, FontStyle.Regular);
        }

        private void BtnEntrar_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.desenharBorda(e, sender, 2, 30, Color.Black);
        }

        private void BtnEntrar_Click(object sender, EventArgs e)
        {

        }

        private void LblVoltar_Click(object sender, EventArgs e)
        {
            TelaEntrarHospital objTelaEntrarHospital = new TelaEntrarHospital();
            objTelaEntrarHospital.Show();
            this.Hide();
        }
    }
}
