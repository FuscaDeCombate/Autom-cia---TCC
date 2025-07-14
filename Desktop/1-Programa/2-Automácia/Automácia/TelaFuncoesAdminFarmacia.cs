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
    public partial class TelaFuncoesAdminFarmacia : Form
    {
        //---------------------------------------------Parte da Navegação--------------------------------------------
        // Para saber qual botão da navegação está selecionado e mudar no OnPaint de cada um
        String selecionado = "";



        //---------------------------------------------Parte da função de Ver Funcionarios--------------------------------------------
        // Para saber se o TxtPesquisar está ou não selecionado e mudar no OnPaint de cada um
        Boolean selecionadoTxtBox = false;

        // Lista dos funcionarios
        List<Button> funcionarios = new List<Button>();

        // (Provisório) Gerador aleatório do número de funcionarios
        static Random rd = new Random();
        static int totalBotoes = rd.Next(1, 100);

        // (Provisório) Lista dos funcionários deletados para a função deletar
        List<int> deletados = new List<int>();

        // (Provisório) Lista da quantidade de receitas emitidas
        List<int> receitas = new List<int>();



        //---------------------------------------------Parte da função de Emitir Receita---------------------------------------------
        RichTextBoxTransparente TxtPrescricao = new RichTextBoxTransparente();



        //---------------------------------------------Parte da função de Gerenciar Funcionários---------------------------------------------
        int indiceFuncSelecionado;



        public TelaFuncoesAdminFarmacia()
        {
            InitializeComponent();
            this.DoubleBuffered = true;
        }

        private void TelaFuncoesAdminFarmacia_Load(object sender, EventArgs e)
        {
            EstiloUtils.ArredondarTudo(PnlFuncoes, 12);


            //---------------------------------------------Parte da Navegação--------------------------------------------
            //----------Aplicar a fonte personalizada nos controles----------
            // Buttons
            FonteUtils.AplicarFonte(BtnVerFuncionarios, "Inter-Bold", 16.501f, FontStyle.Bold);
            FonteUtils.AplicarFonte(BtnCadastrarFuncionario, "Inter-Bold", 16.501f, FontStyle.Bold);
            FonteUtils.AplicarFonte(BtnGerenciarFuncionario, "Inter-Bold", 16.501f, FontStyle.Bold);


            //----------Arredondar os controles----------
            // Panels
            EstiloUtils.ArredondarCantos(PnlNavegacao, 12, true, true, false, false);

            // Buttons
            EstiloUtils.ArredondarCantos(BtnVerFuncionarios, 16, true, false, false, false);
            EstiloUtils.ArredondarCantos(BtnGerenciarFuncionario, 16, false, true, false, false);



            //---------------------------------------------Parte da função de Ver Funcionarios--------------------------------------------
            //----------Aplicar a fonte personalizada nos controles----------
            // TextBoxs
            FonteUtils.AplicarFonte(TxtPesquisarNome, "Inter-Regular", 16f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtVerNome, "Inter-Regular", 12.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtVerCNPJ, "Inter-Regular", 12.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtVerCRF, "Inter-Regular", 12.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtVerCPF, "Inter-Regular", 12.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtVerEmail, "Inter-Regular", 12.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtVerSenha, "Inter-Regular", 12.5f, FontStyle.Regular);

            // Labels
            FonteUtils.AplicarFonte(LblReceitasAprovadas, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblVerNome, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblVerCNPJ, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblVerCRF, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblVerCPF, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblVerEmail, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblVerSenha, "Inter-Bold", 16.5f, FontStyle.Bold);


            //----------Arredondar os controles----------
            // Panels
            EstiloUtils.ArredondarTudo(PnlConteudoVer, 12);
            EstiloUtils.ArredondarCantos(PnlPesquisarNome, 15, true, true, false, false);
            EstiloUtils.ArredondarTudo(PnlTxtBoxPesquisarNome, 15);
            EstiloUtils.ArredondarCantos(PnlVerFuncionarios, 15, false, false, false, true);
            EstiloUtils.ArredondarCantos(PnlPerfilFuncionario, 15, false, false, true, false);

            // PictureBoxs
            EstiloUtils.ArredondarTudo(PicBoxFotoPerfil, 65);


            //-----------Gerar dinamicamente os funcionarios----------
            for (int i = 0; i < totalBotoes; i++)
            {
                receitas.Add(rd.Next(1, 100));
            }
            GerarFuncionarios();



            //---------------------------------------------Parte da função de Emitir Receita---------------------------------------------
            //----------Aplicar a fonte personalizada nos controles----------
            // TextBoxs
            FonteUtils.AplicarFonte(TxtNomeFuncionario, "Inter-Regular", 20f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtCNPJ, "Inter-Regular", 20f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtCPF, "Inter-Regular", 20f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtCRF, "Inter-Regular", 20f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtEmail, "Inter-Regular", 20f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtSenha, "Inter-Regular", 20f, FontStyle.Regular);

            // Labels
            FonteUtils.AplicarFonte(LblNomeFuncionario, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblCNPJ, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblCPF, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblCRF, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblEmail, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblSenha, "Inter-Bold", 16.5f, FontStyle.Bold);

            // Buttons
            FonteUtils.AplicarFonte(BtnCadastrar, "Inter-Medium", 22f, FontStyle.Regular);


            //----------Arredondar os controles----------
            // Buttons
            EstiloUtils.ArredondarTudo(BtnCadastrar, 30);



            //---------------------------------------------Função de Gerenciar Funcionario---------------------------------------------
            //----------Aplicar a fonte personalizada nos controles----------
            // Buttons
            FonteUtils.AplicarFonte(BtnAlterar, "Inter-Regular", 16f, FontStyle.Regular);
            FonteUtils.AplicarFonte(BtnExcluir, "Inter-Regular", 16f, FontStyle.Regular);


            //----------Arredondar os controles----------
            // Buttons
            EstiloUtils.ArredondarTudo(BtnAlterar, 30);
            EstiloUtils.ArredondarTudo(BtnExcluir, 30);
        }




        //---------------------------------------------Parte dos botões de cima---------------------------------------------
        // Fundo da parte de navegação
        private void PnlNavegacao_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaArredondada(e, sender, 2, 12, true, true, false, false, Color.Black);
        }


        // Evento paint dos botões
        private void BtnVerFuncionarios_Paint(object sender, PaintEventArgs e)
        {
            Control controle = sender as Control;
            if (selecionado == "VerFuncionarios")
            {
                EstiloUtils.DesenharBordaSemBase(e, sender, 4, 10, Color.Black, true);
            }
            else if (selecionado != "")
            {
                EstiloUtils.DesenharBorda(e, sender, 4, false, true, false, false, Color.Black);
            }
        }

        private void BtnCadastrarFuncionario_Paint(object sender, PaintEventArgs e)
        {
            if (selecionado == "CadastrarFuncionario")
            {
                EstiloUtils.DesenharBorda(e, sender, 4, true, false, true, true, Color.Black);
            }
            else if (selecionado != "")
            {
                EstiloUtils.DesenharBorda(e, sender, 4, false, true, false, false, Color.Black);
            }
        }

        private void BtnGerenciarFuncionario_Paint(object sender, PaintEventArgs e)
        {
            Control controle = sender as Control;
            if (selecionado == "GerenciarFuncionario")
            {
                EstiloUtils.DesenharBordaSemBase(e, sender, 4, 10, Color.Black, false);
            }
            else if (selecionado != "")
            {
                EstiloUtils.DesenharBorda(e, sender, 4, false, true, false, false, Color.Black);
            }
        }


        // Evento click dos botões
        private void BtnVerFuncionarios_Click(object sender, EventArgs e)
        {
            selecionado = "VerFuncionarios";

            PnlFuncaoVerFuncionarios.Visible = true;
            PnlFuncaoCadastrarFuncionario.Visible = false;

            BtnVerFuncionarios.ForeColor = Color.Black;
            BtnCadastrarFuncionario.ForeColor = Color.Gray;
            BtnGerenciarFuncionario.ForeColor = Color.Gray;

            BtnAlterar.Visible = false;
            BtnExcluir.Visible = false;

            BtnVerFuncionarios.Invalidate();
            BtnCadastrarFuncionario.Invalidate();
            BtnGerenciarFuncionario.Invalidate();
        }

        private void BtnCadastrarFuncionario_Click(object sender, EventArgs e)
        {
            selecionado = "CadastrarFuncionario";

            PnlFuncaoVerFuncionarios.Visible = false;
            PnlFuncaoCadastrarFuncionario.Visible = true;

            BtnVerFuncionarios.ForeColor = Color.Gray;
            BtnCadastrarFuncionario.ForeColor = Color.Black;
            BtnGerenciarFuncionario.ForeColor = Color.Gray;

            BtnVerFuncionarios.Invalidate();
            BtnCadastrarFuncionario.Invalidate();
            BtnGerenciarFuncionario.Invalidate();
        }

        private void BtnGerenciarFuncionario_Click(object sender, EventArgs e)
        {
            selecionado = "GerenciarFuncionario";

            PnlFuncaoVerFuncionarios.Visible = true;
            PnlFuncaoCadastrarFuncionario.Visible = false;

            BtnVerFuncionarios.ForeColor = Color.Gray;
            BtnCadastrarFuncionario.ForeColor = Color.Gray;
            BtnGerenciarFuncionario.ForeColor = Color.Black;

            BtnAlterar.Visible = true;
            BtnExcluir.Visible = true;

            BtnVerFuncionarios.Invalidate();
            BtnCadastrarFuncionario.Invalidate();
            BtnGerenciarFuncionario.Invalidate();
        }



        //---------------------------------------------Os fundos de cada função---------------------------------------------
        private void PnlFuncaoVerFuncionarios_Paint(object sender, PaintEventArgs e)
        {
            Control controle = sender as Control;
            EstiloUtils.DesenharBordaArredondada(e, sender, 6, 12, false, false, true, true, Color.Black);
            EstiloUtils.DesenharBorda(e, sender, 6, true, false, false, false, controle.BackColor);
        }

        private void PnlFuncaoCadastrarFuncionario_Paint(object sender, PaintEventArgs e)
        {
            Control controle = sender as Control;
            EstiloUtils.DesenharBordaArredondada(e, sender, 6, 12, false, false, true, true, Color.Black);
            EstiloUtils.DesenharBorda(e, sender, 6, true, false, false, false, controle.BackColor);
        }



        //---------------------------------------------Função de Ver Funcionarios---------------------------------------------
        // Fundo de Ver Funcionarios
        private void PnlConteudoVer_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 3, 12, Color.Black);
        }


        // Fundo das divisórias
        private void PnlPesquisarNome_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 3, false, true, false, false, Color.Black);
        }

        private void PnlVerFuncionarios_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 1, true, false, false, false, Color.Black);
        }

        private void PnlCasosMedicos_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 3, false, false, true, false, Color.Black);
            EstiloUtils.DesenharBorda(e, sender, 3, false, false, false, true, Color.FromArgb(64, 0, 0, 0));
            EstiloUtils.DesenharBorda(e, sender, 1, true, false, false, false, Color.Black);
        }

        private void PnlPerfilFuncionario_Paint(object sender, PaintEventArgs e)
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
                foreach (var Button in funcionarios)
                {
                    if (Button.Text == TxtPesquisarNome.Text)
                    {
                        pacienteValido = true;
                        break;
                    }
                }
                if (pacienteValido)
                {
                    PnlPerfilFuncionario.Visible = true;

                    TxtVerNome.Text = TxtPesquisarNome.Text;
                    //...
                    //TxtVerCNPJ.Text = .Text;
                    //TxtVerCRM.Text = .Text;
                    //TxtVerCPF.Text = .Text;
                    //TxtVerEmail.Text = .Text;
                    //TxtVerSenha.Text = .Text;
                }
                else
                {
                    MessageBox.Show("Esse funcionario não existe!", "Atenção!");
                }
                e.Handled = true;
                e.SuppressKeyPress = true; // impede o "beep" padrão
            }
        }


        // Função de Receitas Emitidas
        private void LblReceitasAprovadas_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 3, false, true, false, false, Color.FromArgb(64, 0, 0, 0));
        }


        // Função de Perfil do Funcionario
        private void PicBoxFotoPerfil_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 145, Color.Black);
        }

        private void PnlTxtBoxVerNome_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        private void PnlTxtBoxVerCNPJ_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        private void PnlTxtBoxVerCRF_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        private void PnlTxtBoxVerCPF_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        private void PnlTxtBoxVerEmail_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        private void PnlTxtBoxVerSenha_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }


        //-----------Gerar dinamicamente os funcionarios----------
        private void GerarFuncionarios()
        {
            // Limpa os botões antigos, se houver
            funcionarios.Clear();
            PnlVerFuncionarios.Controls.Clear();

            int deletadosAteEntao = 0;

            int larguraBotao = PnlVerFuncionarios.Width;
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
                    botao.Text = $"Farmacêutico {i + 1}";
                    botao.Width = larguraBotao;
                    botao.Height = 45;
                    botao.Left = 0;
                    botao.Top = (i - deletadosAteEntao) * 45;
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
                        indiceFuncSelecionado = int.Parse(botao.Name) - 1;
                        PnlPerfilFuncionario.Visible = true;
                        TxtVerNome.Text = botao.Text;
                        //TxtVerCNPJ.Text = .Text;
                        //TxtVerCRM.Text = .Text;
                        //TxtVerCPF.Text = .Text;
                        //TxtVerEmail.Text = .Text;
                        //TxtVerSenha.Text = .Text;
                        //..
                        GerarReceitasEmitidas(int.Parse(botao.Name) - 1);
                    };

                    // Aplicar fonte personalizada nos botões
                    FonteUtils.AplicarFonte(controle, "Inter-Regular", 14f, FontStyle.Regular);

                    // Adicionar button na lista de buttons
                    funcionarios.Add(botao);

                    // Adicionar button no panel
                    PnlVerFuncionarios.Controls.Add(botao);
                }
                else
                {
                    deletadosAteEntao++;
                }
            }
        }


        //-----------Gerar dinamicamente os funcionarios----------
        private void GerarReceitasEmitidas(int index)
        {
            // Limpa os botões antigos, se houver
            PnlReceitasAprovadas.Controls.Clear();

            for (int i = 0; i < receitas[index]; i++)
            {
                int larguraLabel = PnlReceitasAprovadas.Width;
                if (receitas[index] > 12)
                {
                    larguraLabel -= SystemInformation.VerticalScrollBarWidth; // ajuste para scroll
                }

                // (Provisório) Criar data
                string data = "";
                int dia = rd.Next(1, 30);
                int mes = rd.Next(1, 12);
                if (mes == 2)
                {
                    dia = rd.Next(1, 27);
                }
                int ano = rd.Next(1950, 2025);

                if (dia < 10)
                {
                    data += "0";
                }
                data += dia + "/";

                if (mes < 10)
                {
                    data += "0";
                }
                data += mes + "/";

                data += ano;

                // (Provisório) Criar horário
                string horario = "";
                int horas = rd.Next(1, 23);
                int minutos = rd.Next(1, 59);
                int segundos = rd.Next(1, 59);

                if (horas < 10)
                {
                    horario += "0";
                }
                horario += horas + ":";

                if (minutos < 10)
                {
                    horario += "0";
                }
                horario += minutos + ":";

                if (segundos < 10)
                {
                    horario += "0";
                }
                horario += segundos;

                // Criar Label
                Label label = new Label();
                Control controle = label as Control;
                label.Text = $"Receita {i + 1}  {data}  {horario}";
                label.Width = larguraLabel;
                label.Height = 30;
                label.Left = 0;
                label.Top = i * 30;
                label.Margin = Padding.Empty;
                label.Padding = Padding.Empty;
                label.TextAlign = ContentAlignment.MiddleCenter;

                // Estilo flat sem borda padrão
                label.FlatStyle = FlatStyle.Flat;
                label.BackColor = Color.White;
                label.ForeColor = Color.Gray;

                // Borda desenhada à mão
                if (receitas[index] > 12 && i == receitas[index] - 1)
                {
                    label.Paint += (s, f) =>
                    {
                        EstiloUtils.DesenharBorda(f, s, 2, false, false, false, true, Color.FromArgb(64, 0, 0, 0));
                    };
                }
                else
                {
                    label.Paint += (s, f) =>
                    {
                        EstiloUtils.DesenharBorda(f, s, 2, false, true, false, true, Color.FromArgb(64, 0, 0, 0));
                    };
                }

                // Aplicar fonte personalizada nos labels
                FonteUtils.AplicarFonte(controle, "Inter-Regular", 12f, FontStyle.Regular);

                // Adicionar label no panel
                PnlReceitasAprovadas.Controls.Add(label);
            }
        }



        //---------------------------------------------Função de Emitir Receita---------------------------------------------
        private void PnlTxtBoxNomeFuncionario_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        private void PnlTxtBoxCNPJ_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        private void PnlTxtBoxCPF_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        private void PnlTxtBoxCRF_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        private void PnlTxtBoxEmail_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        private void PnlTxtBoxSenha_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        private void BtnCadastrar_Paint(object sender, PaintEventArgs e)
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

        private void BtnCadastrar_Click(object sender, EventArgs e)
        {
            Boolean valido = true;
            foreach (var controle in new[] { TxtNomeFuncionario, TxtCNPJ, TxtCPF, TxtCRF, TxtEmail, TxtSenha })
            {
                if (string.IsNullOrWhiteSpace(controle.Text))
                {
                    valido = false;
                    controle.Focus();
                    MessageBox.Show("Preencha todos os campos!");
                    return; // para no primeiro vazio
                }
            }

            if (valido == true)
            {
                MessageBox.Show("Funcionário Cadastrado");
            }

        }



        //---------------------------------------------Função de Gerenciar Funcionario---------------------------------------------
        private void BtnAlterar_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 30, Color.Black);
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 1, 30, Color.White);
        }

        private void BtnExcluir_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 30, Color.Black);
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 1, 30, Color.White);
        }

        private void BtnAlterar_Click(object sender, EventArgs e)
        {
            if (PnlPerfilFuncionario.Visible == true)
            {
                funcionarios[indiceFuncSelecionado].Text = TxtVerNome.Text;
                //...
            }
            else
            {
                MessageBox.Show("Selecione um funcionáro antes!", "Atenção!");
            }
        }

        private void BtnExcluir_Click(object sender, EventArgs e)
        {
            if (PnlPerfilFuncionario.Visible == true)
            {
                PnlPerfilFuncionario.Visible = false;
                Button btn = funcionarios.Find(b => b.Text == TxtVerNome.Text);
                deletados.Add(int.Parse(btn.Name) - 1);
                GerarFuncionarios();
            }
            else
            {
                MessageBox.Show("Selecione um funcionáro antes!", "Atenção!");
            }
        }

        private void TelaFuncoesAdminFarmacia_FormClosing(object sender, FormClosingEventArgs e)
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

        private void TelaFuncoesAdminFarmacia_FormClosed(object sender, FormClosedEventArgs e)
        {
            Application.Exit();
        }
    }
}
