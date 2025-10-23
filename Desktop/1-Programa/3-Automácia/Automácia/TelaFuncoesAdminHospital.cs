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
    public partial class TelaFuncoesAdminHospital : Form
    {
        //---------------------------------------------Declaração de Variáveis Necessárias--------------------------------------------
        //----------Parte da Navegação----------
        // Para saber qual botão da navegação está selecionado e mudar no OnPaint de cada um
        String selecionado = "";


        //----------Parte da função de Ver Funcionarios----------
        // Para saber se o TxtPesquisar está ou não selecionado e mudar no OnPaint de cada um
        Boolean selecionadoTxtBox = false;

        // Lista dos funcionarios
        List<Button> funcionarios = new List<Button>();


        //----------Parte da função de Emitir Receita----------
        RichTextBoxTransparente TxtPrescricao = new RichTextBoxTransparente();


        //----------Parte da função de Gerenciar Funcionários----------
        int indiceFuncSelecionado;



        public TelaFuncoesAdminHospital()
        {
            InitializeComponent();
            this.DoubleBuffered = true;
        }



        private void TelaFuncoesAdminHospital_Load(object sender, EventArgs e)
        {
            //---------------------------------------------Arredondar o Painel Principal--------------------------------------------
            EstiloUtils.ArredondarTudo(PnlFuncoes, 12);



            //---------------------------------------------Parte da Navegação--------------------------------------------
            //----------Aplicar a fonte personalizada nos controles----------
            // Buttons
            FonteUtils.AplicarFonte(BtnVerFuncionarios, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(BtnCadastrarFuncionario, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(BtnGerenciarFuncionarios, "Inter-Bold", 16.5f, FontStyle.Bold);


            //----------Arredondar os controles----------
            // Panels
            EstiloUtils.ArredondarCantos(PnlNavegacao, 12, true, true, false, false);

            // Buttons
            EstiloUtils.ArredondarCantos(BtnVerFuncionarios, 16, true, false, false, false);
            EstiloUtils.ArredondarCantos(BtnGerenciarFuncionarios, 16, false, true, false, false);



            //---------------------------------------------Parte da função de Ver Funcionarios--------------------------------------------
            //----------Aplicar a fonte personalizada nos controles----------
            // TextBoxs
            FonteUtils.AplicarFonte(TxtPesquisarNome, "Inter-Regular", 16f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtVerID, "Inter-Regular", 12.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtVerNome, "Inter-Regular", 12.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtVerCNPJ, "Inter-Regular", 12.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtVerSenha, "Inter-Regular", 12.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtVerSenhaAdmin, "Inter-Regular", 12.5f, FontStyle.Regular);

            // Labels
            FonteUtils.AplicarFonte(LblReceitasEmitidas, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblVerID, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblVerNome, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblVerCNPJ, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblVerSenha, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblVerSenhaAdmin, "Inter-Bold", 16.5f, FontStyle.Bold);


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
            GerarFuncionarios();



            //---------------------------------------------Parte da função de Cadastrar Funcionário---------------------------------------------
            //----------Aplicar a fonte personalizada nos controles----------
            // TextBoxs
            FonteUtils.AplicarFonte(TxtNomeFuncionario, "Inter-Regular", 20f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtCNPJ, "Inter-Regular", 20f, FontStyle.Regular);
            FonteUtils.AplicarFonte(CmBoxTipoFunc, "Inter-Regular", 20f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtSenhaFunc, "Inter-Regular", 20f, FontStyle.Regular);

            // Labels
            FonteUtils.AplicarFonte(LblNomeFuncionario, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblCNPJ, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblTipoFunc, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblSenhaFunc, "Inter-Bold", 16.5f, FontStyle.Bold);

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
        //----------Paint dos Elementos----------
        // Fundo da parte de navegação
        private void PnlNavegacao_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaArredondada(e, sender, 2, 12, true, true, false, false, Color.Black);
        }

        // Fundo do Button de Ver Funcionários
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

        // Fundo do Button de Cadastrar Funcionários
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

        // Fundo do Button de Gerenciar Funcionários
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


        //----------Evento Click dos Buttons----------
        // Button de Ver Funcionários
        private void BtnVerFuncionarios_Click(object sender, EventArgs e)
        {
            selecionado = "VerFuncionarios";

            PnlFuncaoVerFuncionarios.Visible = true;
            PnlFuncaoCadastrarFuncionario.Visible = false;

            BtnGerenciarFuncionarios.ForeColor = Color.Black;
            BtnCadastrarFuncionario.ForeColor = Color.Gray;

            BtnAlterar.Visible = false;
            BtnExcluir.Visible = false;

            BtnVerFuncionarios.Invalidate();
            BtnCadastrarFuncionario.Invalidate();
            BtnGerenciarFuncionarios.Invalidate();
        }

        // Button de Cadastrar Funcionários
        private void BtnCadastrarFuncionario_Click(object sender, EventArgs e)
        {
            selecionado = "CadastrarFuncionario";

            PnlFuncaoVerFuncionarios.Visible = false;
            PnlFuncaoCadastrarFuncionario.Visible = true;

            BtnGerenciarFuncionarios.ForeColor = Color.Gray;
            BtnCadastrarFuncionario.ForeColor = Color.Black;

            BtnAlterar.Visible = false;
            BtnExcluir.Visible = false;

            BtnVerFuncionarios.Invalidate();
            BtnCadastrarFuncionario.Invalidate();
            BtnGerenciarFuncionarios.Invalidate();
        }

        // Button de Gerenciar Funcionários
        private void BtnGerenciarFuncionario_Click(object sender, EventArgs e)
        {
            selecionado = "GerenciarFuncionario";

            PnlFuncaoVerFuncionarios.Visible = true;
            PnlFuncaoCadastrarFuncionario.Visible = false;

            BtnGerenciarFuncionarios.ForeColor = Color.Gray;
            BtnCadastrarFuncionario.ForeColor = Color.Gray;

            BtnAlterar.Visible = true;
            BtnExcluir.Visible = true;

            BtnVerFuncionarios.Invalidate();
            BtnCadastrarFuncionario.Invalidate();
            BtnGerenciarFuncionarios.Invalidate();
        }



        //---------------------------------------------Os fundos de cada função---------------------------------------------
        // Fundo da função de Ver Funcionários
        private void PnlFuncaoVerFuncionarios_Paint(object sender, PaintEventArgs e)
        {
            Control controle = sender as Control;
            EstiloUtils.DesenharBordaArredondada(e, sender, 6, 12, false, false, true, true, Color.Black);
            EstiloUtils.DesenharBorda(e, sender, 6, true, false, false, false, controle.BackColor);
        }

        // Fundo da função de Cadastrar Funcionários
        private void PnlFuncaoCadastrarFuncionario_Paint(object sender, PaintEventArgs e)
        {
            Control controle = sender as Control;
            EstiloUtils.DesenharBordaArredondada(e, sender, 6, 12, false, false, true, true, Color.Black);
            EstiloUtils.DesenharBorda(e, sender, 6, true, false, false, false, controle.BackColor);
        }



        //---------------------------------------------Função de Ver Funcionarios---------------------------------------------
        //----------Paint dos Elementos----------
        // Fundo de Ver Funcionários
        private void PnlConteudoVer_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 3, 12, Color.Black);
        }

        // Fundo de Pesquisar Nome
        private void PnlPesquisarNome_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 3, false, true, false, false, Color.Black);
        }

        // Fundo de Ver Funcionários
        private void PnlVerFuncionarios_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 1, true, false, false, false, Color.Black);
        }

        // Fundo do Casos Médicos
        private void PnlCasosMedicos_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 3, false, false, true, false, Color.Black);
            EstiloUtils.DesenharBorda(e, sender, 3, false, false, false, true, Color.FromArgb(64, 0, 0, 0));
            EstiloUtils.DesenharBorda(e, sender, 1, true, false, false, false, Color.Black);
        }

        // Fundo do Perfil
        private void PnlPerfilFuncionario_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 1, true, false, false, false, Color.Black);
        }


        //----------Função de Pesquisar Nome----------
        // Fundo do TxtBox de PesquisarNome
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

        // Evento Enter do TxtBox PesquisarNome
        private void TxtPesquisarNome_Enter(object sender, EventArgs e)
        {
            selecionadoTxtBox = true;
            PnlTxtBoxPesquisarNome.Invalidate();
        }

        // Evento Leave do TxtBox PesquisarNome
        private void TxtPesquisarNome_Leave(object sender, EventArgs e)
        {
            selecionadoTxtBox = false;
            PnlTxtBoxPesquisarNome.Invalidate();
        }

        // Evento KeyDown do TxtBox PesquisarNome
        private void TxtPesquisarNome_KeyDown(object sender, KeyEventArgs e)
        {
            try
            {
                // Para detectar se foi pressionado Enter para iniciar a pesquisa
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
                        PicBoxFotoPerfil.Visible = true;

                        LblVerID.Visible = true;
                        LblVerNome.Visible = true;
                        LblVerCNPJ.Visible = true;
                        LblVerSenha.Visible = true;

                        PnlTxtBoxVerID.Visible = true;
                        PnlTxtBoxVerNome.Visible = true;
                        PnlTxtBoxVerCNPJ.Visible = true;
                        PnlTxtBoxVerSenha.Visible = true;

                        PnlPerfilFuncionario.Visible = true;

                        TxtVerID.Text = funcionarios.Find(b => b.Text == TxtPesquisarNome.Text).Name;
                        TxtVerNome.Text = TxtPesquisarNome.Text;
                        TxtVerCNPJ.Text = Funcionario.Cnpj.ToString();
                        TxtVerSenha.Text = "";

                        indiceFuncSelecionado = int.Parse(funcionarios.Find(b => b.Text == TxtPesquisarNome.Text).Name);
                    }
                    else
                    {
                        MessageBox.Show("Esse funcionario não existe!", "Atenção!");
                    }
                    e.Handled = true;
                    e.SuppressKeyPress = true; // impede o "beep" padrão
                }
            }
            catch (Exception ex)
            {
                // Caso algo dê errado, geralmente quando a conexão com o Banco deu errado
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Verifique a sua conexão com o Banco", "ATENÇÃO!!!");
            }
        }


        //----------Função de Receitas Emitidas----------
        // Fundo da Label de Receitas Emitidas
        private void LblReceitasEmitidas_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 3, false, true, false, false, Color.FromArgb(64, 0, 0, 0));
        }


        //----------Função de Receitas Emitidas----------
        // Fundo do PictureBox da foto do perfil
        private void PicBoxFotoPerfil_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 145, Color.Black);
        }

        // Fundo do TextBox de Ver ID
        private void PnlTxtBoxVerID_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        // Fundo do TextBox de Ver Nome
        private void PnlTxtBoxVerNome_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        // Fundo do TextBox de Ver CNPJ
        private void PnlTxtBoxVerCNPJ_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        // Fundo do TextBox de Ver Senha
        private void PnlTxtBoxVerSenha_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        // Fundo do TextBox de Ver Admin
        private void PnlTxtBoxVerSenhaAdmin_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }


        //-----------Gerar dinamicamente os funcionarios----------
        private void GerarFuncionarios()
        {
            try
            {
                // Limpa os botões antigos, se houver
                funcionarios.Clear();
                PnlVerFuncionarios.Controls.Clear();

                ClsBanco objBanco = new ClsBanco();
                DataTable dtFuncionarios = objBanco.ConsultaFuncionarios(Funcionario.Cnpj.ToString(), "senha5");

                int larguraBotao = PnlVerFuncionarios.Width;
                if (dtFuncionarios.Rows.Count > 9)
                {
                    larguraBotao -= SystemInformation.VerticalScrollBarWidth; // ajuste para scroll
                }

                for (int i = 0; i < dtFuncionarios.Rows.Count; i++)
                {
                    //Criar Button
                    Button botao = new Button();
                    Control controle = botao as Control;
                    botao.Text = $"{dtFuncionarios.Rows[i]["Nome_Funcionario"]}";
                    botao.Width = larguraBotao;
                    botao.Height = 45;
                    botao.Left = 0;
                    botao.Top = i * 45;
                    botao.Name = $"{dtFuncionarios.Rows[i]["Funcionar_Rec"]}";

                    // Estilo flat sem borda padrão
                    botao.FlatStyle = FlatStyle.Flat;
                    botao.FlatAppearance.BorderSize = 0;
                    botao.BackColor = Color.White;
                    botao.ForeColor = Color.Black;

                    // Borda desenhada à mão
                    if (dtFuncionarios.Rows.Count > 9 && i == dtFuncionarios.Rows.Count - 1)
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
                        PicBoxFotoPerfil.Visible = true;

                        LblVerID.Visible = true;
                        LblVerNome.Visible = true;
                        LblVerCNPJ.Visible = true;
                        LblVerSenha.Visible = true;

                        PnlTxtBoxVerID.Visible = true;
                        PnlTxtBoxVerNome.Visible = true;
                        PnlTxtBoxVerCNPJ.Visible = true;
                        PnlTxtBoxVerSenha.Visible = true;

                        PnlPerfilFuncionario.Visible = true;

                        TxtVerID.Text = botao.Name;
                        TxtVerNome.Text = botao.Text;
                        TxtVerCNPJ.Text = Funcionario.Cnpj.ToString();
                        TxtVerSenha.Text = "";

                        indiceFuncSelecionado = int.Parse(botao.Name);
                    };

                    // Aplicar fonte personalizada nos botões
                    FonteUtils.AplicarFonte(controle, "Inter-Regular", 14f, FontStyle.Regular);

                    // Adicionar button na lista de buttons
                    funcionarios.Add(botao);

                    // Adicionar button no panel
                    PnlVerFuncionarios.Controls.Add(botao);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Verifique a sua conexão com o Banco", "ATENÇÃO!!!");
            }
        }



        //---------------------------------------------Função de Cadastrar Funcionário---------------------------------------------
        //----------Paint dos Elementos----------
        // Fundo do TextBox do Nome Funcionário
        private void PnlTxtBoxNomeFuncionario_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        // Fundo do TextBox do CNPJ
        private void PnlTxtBoxCNPJ_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        // Fundo do TextBox da Senha do Funcionário
        private void PnlTxtBoxSenhaFunc_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        // Fundo do TextBox da Senha do Administrador
        private void PnlTxtBoxSenhaAdmin_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        // Fundo do Button de Cadastrar
        private void BtnCadastrar_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 30, Color.Black);
        }


        //----------Evento KeyDown dos Elementos----------
        // Para redirecionar para o próximo elemento depois de já preenchido esse espaço
        private void RedirecionarProximo_KeyDown(object sender, KeyEventArgs e)
        {
            try
            {
                if (e.KeyCode == Keys.Enter)
                {
                    Control controle = sender as Control;

                    switch (controle.Name)
                    {
                        case "TxtNomeFuncionario":
                            TxtCNPJ.Focus();
                            break;
                        case "TxtCNPJ":
                            CmBoxTipoFunc.Focus();
                            break;
                        case "CmBoxTipoFunc":
                            TxtSenhaFunc.Focus();
                            break;
                        case "TxtSenhaFunc":
                            BtnCadastrar.Focus();
                            break;
                        case "BtnCadastrar":
                            CadastrarFuncionario();
                            break;
                        default:
                            TxtNomeFuncionario.Focus();
                            break;
                    }
                    e.Handled = true;
                    e.SuppressKeyPress = true; // impede o "beep" padrão
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
        }


        //----------Evento Click dos Elementos----------
        // Button de Cadastrar Funcionário
        private void BtnCadastrar_Click(object sender, EventArgs e)
        {
            CadastrarFuncionario();
        }



        //---------------------------------------------Função de Gerenciar Funcionario---------------------------------------------
        //----------Paint dos Elementos----------
        // Fundo do Button de Alterar
        private void BtnAlterar_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 30, Color.Black);
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 1, 30, Color.White);
        }

        // Fundo do Button de Inativar
        private void BtnInativar_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 30, Color.Black);
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 1, 30, Color.White);
        }


        //----------Evento Click dos Elementos----------
        // Button de Alterar
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

        // Button de Inativar
        private void BtnInativar_Click(object sender, EventArgs e)
        {

        }



        //---------------------------------------------Parte de fechar o programa---------------------------------------------
        // Evento ativado quando o formulário estiver sendo fechado
        private void TelaFuncoesAdminHospital_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (!Sessao.saindo)
            {
                // Confirmação para ver se o programa realmente vai ser fechado
                var confirmar = MessageBox.Show("Deseja realmente sair?", "Sair", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

                if (confirmar == DialogResult.Yes)
                {
                    // Para fechar a Aplicação
                    Sessao.saindo = true;
                    Application.Exit();
                }
                else
                {
                    // Para cancelar o fechamento
                    e.Cancel = true;
                }
            }
        }

        // Evento ativado quando o formulário for fechado
        private void TelaFuncoesAdminHospital_FormClosed(object sender, FormClosedEventArgs e)
        {
            Application.Exit();
        }



        //---------------------------------------------Parte de outras funções---------------------------------------------
        //----------Função de Cadastrar Funcionário----------
        private void CadastrarFuncionario()
        {
            try
            {
                foreach (var controle in new[] { TxtNomeFuncionario, TxtCNPJ, TxtSenhaFunc })
                {
                    if (string.IsNullOrWhiteSpace(controle.Text))
                    {
                        controle.Focus();
                        MessageBox.Show("Preencha todos os campos!");
                        return;
                    }
                }

                int idTipo = 0;
                switch (CmBoxTipoFunc.SelectedIndex)
                {
                    case 0:
                        idTipo = 2;
                        break;
                    case 1:
                        idTipo = 4;
                        break;
                    default:
                        idTipo = 0;
                        break;
                }

                if (string.IsNullOrWhiteSpace(CmBoxTipoFunc.Text) || idTipo == 0)
                {
                    CmBoxTipoFunc.Focus();
                    MessageBox.Show("Preencha todos os campos!");
                    return;
                }

                // Declaração das variáveis mais comuns
                string cnpj = TxtCNPJ.Text;
                int idTipoFuncionario = idTipo;
                string nomeFuncionario = TxtNomeFuncionario.Text;
                string senhaFuncionario = TxtSenhaFunc.Text;

                // Declaração da Classe que pega do Banco e do DataTable necessário
                ClsBanco objBanco = new ClsBanco();
                string retornoCadastro = objBanco.CadastroFuncionario(cnpj, idTipoFuncionario, nomeFuncionario, senhaFuncionario);

                // Verificar se o Cadastro foi inválido
                if (retornoCadastro == "Funcionário registrado com sucesso")
                {
                    MessageBox.Show(retornoCadastro, "Cadastro Sucedido!");

                    foreach (var controle in new[] { TxtNomeFuncionario, TxtCNPJ, TxtSenhaFunc })
                    {
                        controle.Text = "";
                    }
                    CmBoxTipoFunc.SelectedIndex = 0;
                    TxtNomeFuncionario.Focus();
                }
                else
                {
                    MessageBox.Show("Informações inválidas", "Cadastro não Sucedido");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Verifique a sua conexão com o Banco", "ATENÇÃO!!!");
            }
        }
    }
}