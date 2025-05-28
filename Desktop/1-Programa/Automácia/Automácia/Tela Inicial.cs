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
        public TelaInicio()
        {
            InitializeComponent();
        }

        private void TelaInicio_Load(object sender, EventArgs e)
        {
            EstiloUtils.arredondarBorda(GroupEntrar, 15);
            EstiloUtils.arredondarBorda(PicBoxLogo, 90);

            EstiloUtils.arredondarBorda(BtnHospitalEntrar, 30);
            EstiloUtils.arredondarBorda(BtnFarmaciaEntrar, 30);

            FonteUtils.AplicarFonte(LblEntrar, "Inter-Bold", 34f, FontStyle.Bold);
            FonteUtils.AplicarFonte(BtnHospitalEntrar, "Inter-SemiBold", 22f, FontStyle.Regular);
            FonteUtils.AplicarFonte(BtnFarmaciaEntrar, "Inter-SemiBold", 22f, FontStyle.Regular);
        }

        private void PicBoxLogo_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.desenharBorda(e, sender, 2, 90 , Color.Black);
        }

        private void BtnHospitalEntrar_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.desenharBorda(e, sender, 2, 30, Color.Black);
        }

        private void BtnFarmaciaEntrar_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.desenharBorda(e, sender, 2, 30, Color.Black);
        }

        private void BtnHospitalEntrar_Click(object sender, EventArgs e)
        {
            TelaEntrarHospital objTelaEntrarHospital = new TelaEntrarHospital();
            objTelaEntrarHospital.Show();
            this.Hide();
        }

        private void BtnFarmaciaEntrar_Click(object sender, EventArgs e)
        {
            TelaEntrarFarmacia objTelaEntrarFarmacia = new TelaEntrarFarmacia();
            objTelaEntrarFarmacia.Show();
            this.Hide();
        }
    }
}