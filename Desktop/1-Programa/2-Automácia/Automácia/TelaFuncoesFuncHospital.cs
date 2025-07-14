using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Runtime.InteropServices;

namespace Automácia
{
    public partial class TelaFuncoesFuncHospital : Form
    {
        private const int EM_GETLINECOUNT = 0x00BA;
        private bool bloqueandoTexto = false;

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern int SendMessage(IntPtr hWnd, int msg, int wParam, int lParam);

        //---------------------------------------------Parte da Navegação--------------------------------------------
        // Para saber qual botão da navegação está selecionado e mudar no OnPaint de cada um
        String selecionado = "";



        //---------------------------------------------Parte da função de Ver Pacientes--------------------------------------------
        // Para saber se o TxtPesquisar está ou não selecionado e mudar no OnPaint de cada um
        Boolean selecionadoTxtBox = false;

        // Lista dos pacientes
        List<Button> pacientes = new List<Button>();

        // (Provisório) Gerador aleatório do número de pacientes
        static Random rd = new Random();
        static int totalBotoes = rd.Next(1, 100);

        List<int> deletados = new List<int>();



        //---------------------------------------------Parte da função de Emitir Receita---------------------------------------------
        RichTextBoxTransparente TxtPrescricao = new RichTextBoxTransparente();

        public TelaFuncoesFuncHospital()
        {
            InitializeComponent();
            this.DoubleBuffered = true;
        }

        private void TelaFuncoesFuncHospital_Load(object sender, EventArgs e)
        {
            EstiloUtils.ArredondarTudo(PnlFuncoes, 12);


            //---------------------------------------------Parte da Navegação--------------------------------------------
            //----------Aplicar a fonte personalizada nos controles----------
            // Buttons
            FonteUtils.AplicarFonte(BtnVerPacientes, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(BtnEmitirReceita, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(BtnGerenciarPacientes, "Inter-Bold", 16.5f, FontStyle.Bold);

            //----------Arredondar os controles----------
            // Panels
            EstiloUtils.ArredondarCantos(PnlNavegacao, 12, true, true, false, false);

            // Buttons
            EstiloUtils.ArredondarCantos(BtnVerPacientes, 16, true, false, false, false);
            EstiloUtils.ArredondarCantos(BtnGerenciarPacientes, 16, false, true, false, false);



            //---------------------------------------------Parte da função de Ver Pacientes--------------------------------------------
            //----------Aplicar a fonte personalizada nos controles----------
            // TextBoxs
            FonteUtils.AplicarFonte(TxtPesquisarNome, "Inter-Regular", 16f, FontStyle.Regular);

            // Labels
            FonteUtils.AplicarFonte(LblHistoricoMedico, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblVerNome, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblVerNomePaciente, "Inter-Regular", 16f, FontStyle.Regular);


            //----------Arredondar os controles----------
            // Panels
            EstiloUtils.ArredondarTudo(PnlConteudoVer, 12);
            EstiloUtils.ArredondarCantos(PnlPesquisarNome, 15, true, true, false, false);
            EstiloUtils.ArredondarTudo(PnlTxtBoxPesquisarNome, 15);
            EstiloUtils.ArredondarCantos(PnlVerPacientes, 15, false, false, false, true);
            EstiloUtils.ArredondarCantos(PnlPerfilPaciente, 15, false, false, true, false);

            // PictureBoxs
            EstiloUtils.ArredondarTudo(PicBoxFotoPerfil, 90);


            //-----------Gerar dinamicamente os pacientes----------
            GerarPacientes();



            //---------------------------------------------Parte da função de Emitir Receita---------------------------------------------
            //----------Aplicar a fonte personalizada nos controles----------
            // TextBoxs
            FonteUtils.AplicarFonte(TxtNomePaciente, "Inter-Regular", 20f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtCPF, "Inter-Regular", 20f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtCRM, "Inter-Regular", 20f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtUso, "Inter-Regular", 20f, FontStyle.Regular);

            // Labels
            FonteUtils.AplicarFonte(LblNomePaciente, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblCPF, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblCRM, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblUso, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblPrescricao, "Inter-Bold", 16.5f, FontStyle.Bold);

            // Buttons
            FonteUtils.AplicarFonte(BtnEmitir, "Inter-Medium", 22f, FontStyle.Regular);


            //----------Criar o textbox com fundo transparente----------
            TxtPrescricao.Size = PnlTxtBoxPrescricao.Size;
            TxtPrescricao.Font = new Font("Inter-Regular", 20);
            TxtPrescricao.Location = new Point(0, 0);
            TxtPrescricao.ScrollBars = RichTextBoxScrollBars.None;
            TxtPrescricao.TextChanged += (s, f) =>
            {
                if (bloqueandoTexto) return;

                int linhaRenderizada = SendMessage(TxtPrescricao.Handle, EM_GETLINECOUNT, 0, 0);

                if (linhaRenderizada > 2)
                {
                    bloqueandoTexto = true;

                    // Remove o último caractere que causou excesso
                    int pos = TxtPrescricao.SelectionStart;
                    if (pos > 0)
                    {
                        TxtPrescricao.Text = TxtPrescricao.Text.Remove(pos - 1, 1);
                        TxtPrescricao.SelectionStart = pos - 1;
                    }

                    bloqueandoTexto = false;
                }
            };

            PnlTxtBoxPrescricao.Controls.Add(TxtPrescricao);


            //----------Arredondar os controles----------
            // Buttons
            EstiloUtils.ArredondarTudo(BtnEmitir, 30);



            //---------------------------------------------Função de Gerenciar Pacientes---------------------------------------------
            //----------Aplicar a fonte personalizada nos controles----------
            // Buttons
            FonteUtils.AplicarFonte(BtnExcluir, "Inter-Regular", 16f, FontStyle.Regular);


            //----------Arredondar os controles----------
            // Buttons
            EstiloUtils.ArredondarTudo(BtnExcluir, 30);
        }




        //---------------------------------------------Parte dos botões de cima---------------------------------------------
        // Fundo da parte de navegação
        private void PnlNavegacao_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaArredondada(e, sender, 2, 12, true, true, false, false, Color.Black);
        }


        // Evento paint dos botões
        private void BtnVerPacientes_Paint(object sender, PaintEventArgs e)
        {
            Control controle = sender as Control;
            if (selecionado == "VerPacientes")
            {
                EstiloUtils.DesenharBordaSemBase(e, sender, 4, 10, Color.Black, true);
            }
            else if (selecionado != "")
            {
                EstiloUtils.DesenharBorda(e, sender, 4, false, true, false, false, Color.Black);
            }
        }

        private void BtnEmitirReceita_Paint(object sender, PaintEventArgs e)
        {
            if (selecionado == "EmitirReceita")
            {
                EstiloUtils.DesenharBorda(e, sender, 4, true, false, true, true, Color.Black);
            }
            else if (selecionado != "")
            {
                EstiloUtils.DesenharBorda(e, sender, 4, false, true, false, false, Color.Black);
            }
        }

        private void BtnGerenciarPacientes_Paint(object sender, PaintEventArgs e)
        {
            Control controle = sender as Control;
            if (selecionado == "GerenciarPacientes")
            {
                EstiloUtils.DesenharBordaSemBase(e, sender, 4, 10, Color.Black, false);
            }
            else if (selecionado != "")
            {
                EstiloUtils.DesenharBorda(e, sender, 4, false, true, false, false, Color.Black);
            }
        }


        // Evento click dos botões
        private void BtnVerPacientes_Click(object sender, EventArgs e)
        {
            selecionado = "VerPacientes";

            PnlFuncaoVerPacientes.Visible = true;
            PnlFuncaoEmitirReceita.Visible = false;

            BtnVerPacientes.ForeColor = Color.Black;
            BtnEmitirReceita.ForeColor = Color.Gray;
            BtnGerenciarPacientes.ForeColor = Color.Gray;

            BtnExcluir.Visible = false;

            BtnVerPacientes.Invalidate();
            BtnEmitirReceita.Invalidate();
            BtnGerenciarPacientes.Invalidate();
        }

        private void BtnEmitirReceita_Click(object sender, EventArgs e)
        {
            selecionado = "EmitirReceita";

            PnlFuncaoVerPacientes.Visible = false;
            PnlFuncaoEmitirReceita.Visible = true;

            BtnVerPacientes.ForeColor = Color.Gray;
            BtnEmitirReceita.ForeColor = Color.Black;
            BtnGerenciarPacientes.ForeColor = Color.Gray;

            BtnVerPacientes.Invalidate();
            BtnEmitirReceita.Invalidate();
            BtnGerenciarPacientes.Invalidate();
        }

        private void BtnGerenciarPacientes_Click(object sender, EventArgs e)
        {
            selecionado = "GerenciarPacientes";

            PnlFuncaoVerPacientes.Visible = true;
            PnlFuncaoEmitirReceita.Visible = false;

            BtnVerPacientes.ForeColor = Color.Gray;
            BtnEmitirReceita.ForeColor = Color.Gray;
            BtnGerenciarPacientes.ForeColor = Color.Black;

            BtnExcluir.Visible = true;

            BtnVerPacientes.Invalidate();
            BtnEmitirReceita.Invalidate();
            BtnGerenciarPacientes.Invalidate();
        }



        //---------------------------------------------Os fundos de cada função---------------------------------------------
        private void PnlFuncaoVerPacientes_Paint(object sender, PaintEventArgs e)
        {
            Control controle = sender as Control;
            EstiloUtils.DesenharBordaArredondada(e, sender, 6, 12, false, false, true, true, Color.Black);
            EstiloUtils.DesenharBorda(e, sender, 6, true, false, false, false, controle.BackColor);
        }

        private void PnlFuncaoEmitirReceita_Paint(object sender, PaintEventArgs e)
        {
            Control controle = sender as Control;
            EstiloUtils.DesenharBordaArredondada(e, sender, 6, 12, false, false, true, true, Color.Black);
            EstiloUtils.DesenharBorda(e, sender, 6, true, false, false, false, controle.BackColor);
        }



        //---------------------------------------------Função de Ver Pacientes---------------------------------------------
        // Fundo de Ver Pacientes
        private void PnlConteudoVer_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 3, 12, Color.Black);
        }


        // Fundo das divisórias
        private void PnlPesquisarNome_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 3, false, true, false, false, Color.Black);
        }

        private void PnlVerPacientes_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 1, true, false, false, false, Color.Black);
        }

        private void PnlHistoricoMedico_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 3, false, false, true, false, Color.Black);
            EstiloUtils.DesenharBorda(e, sender, 3, false, false, false, true, Color.FromArgb(64, 0, 0, 0));
            EstiloUtils.DesenharBorda(e, sender, 1, true, false, false, false, Color.Black);

        }

        private void PnlPerfilPaciente_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 1, true, false, false, false, Color.Black);
        }


        // Função de Pesquisar Nome
        private void PnlTxtBoxPesquisarNome_Paint(object sender, PaintEventArgs e)
        {
            if (selecionadoTxtBox)
            {
                EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 12, ColorTranslator.FromHtml("#00B2FF"));
            }
            else
            {
                EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 12, Color.Black);
            }
        }

        private void TxtPesquisarNome_Enter(object sender, EventArgs e)
        {
            selecionadoTxtBox = true;
            PnlTxtBoxPesquisarNome.Invalidate();
        }

        private void TxtPesquisarNome_Leave(object sender, EventArgs e)
        {
            selecionadoTxtBox = false;
            PnlTxtBoxPesquisarNome.Invalidate();
        }

        private void TxtPesquisarNome_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                Boolean pacienteValido = false;
                foreach (var Button in pacientes)
                {
                    if (Button.Text == TxtPesquisarNome.Text)
                    {
                        pacienteValido = true;
                        break;
                    }
                }
                if (pacienteValido)
                {
                    LblVerNome.Visible = true;
                    PicBoxFotoPerfil.Visible = true;
                    LblVerNomePaciente.Visible = true;
                    PicBoxHistoricoMedico.Visible = true;
                    LblVerNomePaciente.Text = TxtPesquisarNome.Text;
                }
                else
                {
                    MessageBox.Show("Esse paciente não existe!");
                }
                e.Handled = true;
                e.SuppressKeyPress = true; // impede o "beep" padrão
            }
        }


        // Função de Histórico Médico
        private void LblHistoricoMedico_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 3, false, true, false, false, Color.FromArgb(64, 0, 0, 0));
        }


        // Função de Perfil do Paciente
        private void PicBoxFotoPerfil_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 170, Color.Black);
        }


        private void GerarPacientes()
        {
            //-----------Gerar dinamicamente os pacientes----------
            // Limpa os botões antigos, se houver
            pacientes.Clear();
            PnlVerPacientes.Controls.Clear();

            int deletadosAteEntao = 0;

            int larguraBotao = PnlVerPacientes.Width;
            if (totalBotoes > 9)
            {
                larguraBotao -= SystemInformation.VerticalScrollBarWidth; // ajuste para scroll
            }

            for (int i = 0; i < totalBotoes; i++)
            {
                if (!deletados.Contains(i))
                {
                    //Criar Button
                    Button botao = new Button();
                    Control controle = botao as Control;
                    botao.Text = $"Paciente {i + 1}";
                    botao.Width = larguraBotao;
                    botao.Height = 44;
                    botao.Left = 0;
                    botao.Top = (i - deletadosAteEntao) * 44;
                    botao.Name = $"{i + 1}";

                    // Estilo flat sem borda padrão
                    botao.FlatStyle = FlatStyle.Flat;
                    botao.FlatAppearance.BorderSize = 0;
                    botao.BackColor = Color.White;
                    botao.ForeColor = Color.Black;

                    // Borda desenhada à mão
                    if (totalBotoes > 9 && i == totalBotoes - 1)
                    {
                        botao.Paint += (s, f) =>
                        {
                            EstiloUtils.DesenharBorda(f, s, 2, false, false, false, true, Color.Black);
                        };
                    }
                    else
                    {
                        botao.Paint += (s, f) =>
                        {
                            EstiloUtils.DesenharBorda(f, s, 2, false, true, false, true, Color.Black);
                        };
                    }

                    // Clique do botão
                    botao.Click += (s, f) =>
                    {
                        LblVerNome.Visible = true;
                        PicBoxFotoPerfil.Visible = true;
                        LblVerNomePaciente.Visible = true;
                        PicBoxHistoricoMedico.Visible = true;
                        LblVerNomePaciente.Text = botao.Text;
                    };

                    // Aplicar fonte personalizada nos botões
                    FonteUtils.AplicarFonte(controle, "Inter-Regular", 16.501f, FontStyle.Regular);

                    // Adicionar button na lista de buttons
                    pacientes.Add(botao);

                    // Adicionar button no panel
                    PnlVerPacientes.Controls.Add(botao);
                }
                else
                {
                    deletadosAteEntao++;
                }
            }
        }



        //---------------------------------------------Função de Emitir Receita---------------------------------------------
        private void PnlTxtBoxNomePaciente_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        private void PnlTxtBoxCPF_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        private void PnlTxtBoxCRM_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        private void PnlTxtBoxUso_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        private void PnlTxtBoxPrescricao_Paint(object sender, PaintEventArgs e)
        {
            int espacamento = 32;
            using (Pen caneta = new Pen(Color.Black, 2))
            {
                for (int y = espacamento; y < PnlTxtBoxPrescricao.Height; y += espacamento)
                {
                    e.Graphics.DrawLine(caneta, 0, y, PnlTxtBoxPrescricao.Width, y);
                }
            }
        }

        private void BtnEmitir_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 30, Color.Black);
        }

        private void Numerico_KeyPress(object sender, KeyPressEventArgs e)
        {
            // Permitir apenas números e teclas de controle (como Backspace)
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar))
            {
                e.Handled = true;
            }
        }

        private void BtnEmitir_Click(object sender, EventArgs e)
        {
            Boolean valido = true;
            foreach (var controle in new[] { TxtNomePaciente, TxtCPF, TxtCRM, TxtUso })
            {
                if (string.IsNullOrWhiteSpace(controle.Text))
                {
                    valido = false;
                    controle.Focus();
                    MessageBox.Show("Preencha todos os campos!");
                    return; // para no primeiro vazio
                }
            }

            if (string.IsNullOrWhiteSpace(TxtPrescricao.Text))
            {
                valido = false;
                TxtPrescricao.Focus();
                MessageBox.Show("Preencha todos os campos!");
                return;
            }

            if (valido == true)
            {
                MessageBox.Show("Receita Emitida");
            }

        }



        //---------------------------------------------Função de Gerenciar Pacientes---------------------------------------------
        private void BtnExcluir_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 30, Color.Black);
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 1, 30, Color.White);
        }

        private void BtnExcluir_Click(object sender, EventArgs e)
        {
            if (LblVerNomePaciente.Visible == true)
            {
                LblVerNome.Visible = false;
                LblVerNomePaciente.Visible = false;
                PicBoxFotoPerfil.Visible = false;
                Button btn = pacientes.Find(b => b.Text == LblVerNomePaciente.Text);
                deletados.Add(int.Parse(btn.Name)-1);
                GerarPacientes();
            }
            else
            {
                MessageBox.Show("Selecione um paciente antes!", "Atenção!");
            }
        }

        private void TelaFuncoesFuncHospital_FormClosing(object sender, FormClosingEventArgs e)
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

        private void TelaFuncoesFuncHospital_FormClosed(object sender, FormClosedEventArgs e)
        {
            Application.Exit();
        }
    }
}
