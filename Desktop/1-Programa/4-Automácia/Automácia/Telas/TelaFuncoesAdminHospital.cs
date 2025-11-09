using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Media;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Automácia
{
    public partial class TelaFuncoesAdminHospital : Form
    {
        //---------------------------------------------Declaração de Variáveis Necessárias--------------------------------------------
        //----------Declaração da tela da Receita----------
        private static TelaReceita objTelaReceita;


        //----------Parte da Navegação----------
        // Para saber qual botão da navegação está selecionado e mudar no OnPaint de cada um
        String selecionado = "";


        //----------Parte da função de Ver Funcionarios----------
        // Para saber se o TxtPesquisar está ou não selecionado e mudar no OnPaint de cada um
        Boolean selecionadoTxtBox = false;

        // Lista dos Funcionarios
        List<Button> funcionarios = new List<Button>();

        // Lista das Receitas
        List<Receita> receita = new List<Receita>();


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
            FonteUtils.AplicarFonte(TxtSenhaContratante, "Inter-Regular", 12.5f, FontStyle.Regular);

            // Labels
            FonteUtils.AplicarFonte(LblReceitasEmitidas, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblVerID, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblVerNome, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblVerCNPJ, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblVerSenha, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblSenhaContratante, "Inter-Bold", 16.5f, FontStyle.Bold);


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
            FonteUtils.AplicarFonte(TxtSenhaAdmin, "Inter-Regular", 20f, FontStyle.Regular);

            // Labels
            FonteUtils.AplicarFonte(LblNomeFuncionario, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblCNPJ, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblTipoFunc, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblSenhaFunc, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblSenhaAdmin, "Inter-Bold", 16.5f, FontStyle.Bold);

            // Buttons
            FonteUtils.AplicarFonte(BtnCadastrar, "Inter-Medium", 22f, FontStyle.Regular);


            //----------Arredondar os controles----------
            // Buttons
            EstiloUtils.ArredondarTudo(BtnCadastrar, 30);


            //---------- Definir Index Inicial do ComboBox ----------
            CmBoxTipoFunc.SelectedIndex = 0;



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

            BtnVerFuncionarios.ForeColor = Color.Black;
            BtnCadastrarFuncionario.ForeColor = Color.Gray;
            BtnGerenciarFuncionarios.ForeColor = Color.Gray;

            LblSenhaContratante.Visible = false;
            PnlTxtBoxSenhaContratante.Visible = false;
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

            BtnVerFuncionarios.ForeColor = Color.Gray;
            BtnCadastrarFuncionario.ForeColor = Color.Black;
            BtnGerenciarFuncionarios.ForeColor = Color.Gray;

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

            BtnVerFuncionarios.ForeColor = Color.Gray;
            BtnCadastrarFuncionario.ForeColor = Color.Gray;
            BtnGerenciarFuncionarios.ForeColor = Color.Black;

            LblSenhaContratante.Visible = true;
            PnlTxtBoxSenhaContratante.Visible = true;
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

                    // Verificar se o Paciente é Válido
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

                        // Inserindo as Informações do Funcionário
                        TxtVerID.Text = funcionarios.Find(b => b.Text == TxtPesquisarNome.Text).Name;
                        TxtVerNome.Text = TxtPesquisarNome.Text;
                        TxtVerCNPJ.Text = Funcionario.Cnpj.ToString();
                        TxtVerSenha.Text = "";

                        indiceFuncSelecionado = int.Parse(funcionarios.Find(b => b.Text == TxtPesquisarNome.Text).Name);
                    }
                    else
                    {
                        MessageBox.Show("Esse funcionario não existe!", "ATENÇÃO!!!");
                    }
                    e.Handled = true;
                    e.SuppressKeyPress = true; // impede o "beep" padrão
                }
            }
            catch (Exception ex)
            {
                // Caso algo dê errado, geralmente quando a conexão com o Banco deu errado
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Verifique a sua conexão com o Banco!", "ATENÇÃO!!!");
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
                // Verificar se a tecla apertada foi Enter
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
            try
            {
                if (PnlPerfilFuncionario.Visible == true)
                {
                    // Para verificar se o controle está vazio, e então deixar esse controle em Focus()
                    foreach (var controle in new[] { TxtVerID, TxtVerNome, TxtVerCNPJ })
                    {
                        if (string.IsNullOrWhiteSpace(controle.Text))
                        {
                            TxtPesquisarNome.Focus();
                            SystemSounds.Beep.Play(); // cria o "beep" padrão
                            MessageBox.Show("Dados Inválidos!", "Funcionário Inválido!!!");
                            return;
                        }
                    }

                    // Para verificar se o controle está vazio, e então deixar esse controle em Focus()
                    foreach (var controle in new[] { TxtVerSenha, TxtSenhaContratante })
                    {
                        if (string.IsNullOrWhiteSpace(controle.Text))
                        {
                            controle.Focus();
                            SystemSounds.Beep.Play(); // cria o "beep" padrão
                            MessageBox.Show("Preencha todos os campos!", "ATENÇÃO!!!");
                            return;
                        }
                    }

                    // Declaração das variáveis mais comuns
                    int idFuncionario = int.Parse(TxtVerID.Text);
                    string cnpj = TxtVerCNPJ.Text;
                    string novaSenha = TxtVerSenha.Text;
                    string senhaContratante = TxtSenhaContratante.Text;

                    // Declaração da Classe que pega do Banco e do DataTable necessário
                    ClsBanco objBanco = new ClsBanco();
                    string retornoAltera = objBanco.AlterarFuncionario(idFuncionario, novaSenha, cnpj, senhaContratante);

                    // Verificar se a Alteração foi Válida
                    if (retornoAltera == "Senha do funcionário alterada com sucesso")
                    {
                        // Caso se a Alteração tenha sido Válida
                        MessageBox.Show(retornoAltera+ "!", "Alteração Sucedida!!!");

                        // Reseta os Controles
                        TxtVerSenha.Clear();
                        TxtSenhaContratante.Clear();

                        TxtVerSenha.Focus();
                    }
                    else
                    {
                        // Caso a Alteração tenha sido Inválida
                        TxtVerSenha.Focus();
                        SystemSounds.Beep.Play(); // cria o "beep" padrão
                        MessageBox.Show("Informações inválidas!", "Cadastro não Sucedido!!!");
                    }
                }
                else
                {
                    TxtPesquisarNome.Focus();
                    SystemSounds.Beep.Play(); // cria o "beep" padrão
                    MessageBox.Show("Selecione um funcionáro antes!", "ATENÇÃO!!!");
                }
            }
            catch (Exception ex)
            {
                // Caso algo dê errado, geralmente quando a conexão com o Banco deu errado
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Verifique a sua conexão com o Banco!", "ATENÇÃO!!!");
            }
        }

        // Button de Inativar
        private void BtnInativar_Click(object sender, EventArgs e)
        {
            try
            {
                if (PnlPerfilFuncionario.Visible == true)
                {
                    // Para verificar se o controle está vazio, e então deixar esse controle em Focus()
                    foreach (var controle in new[] { TxtVerID, TxtVerNome, TxtVerCNPJ })
                    {
                        if (string.IsNullOrWhiteSpace(controle.Text))
                        {
                            TxtPesquisarNome.Focus();
                            SystemSounds.Beep.Play(); // cria o "beep" padrão
                            MessageBox.Show("Dados Inválidos!", "Funcionário Inválido!!!");
                            return;
                        }
                    }

                    // Para verificar se o controle está vazio, e então deixar esse controle em Focus()
                    foreach (var controle in new[] { TxtSenhaContratante })
                    {
                        if (string.IsNullOrWhiteSpace(controle.Text))
                        {
                            controle.Focus();
                            SystemSounds.Beep.Play(); // cria o "beep" padrão
                            MessageBox.Show("Confira as credenciais inseridas!", "ATENÇÃO!!!");
                            return;
                        }
                    }

                    // Declaração das variáveis mais comuns
                    int idFuncionario = int.Parse(TxtVerID.Text);
                    string cnpj = TxtVerCNPJ.Text;
                    string novaSenha = TxtVerSenha.Text;
                    string senhaContratante = TxtSenhaContratante.Text;

                    // Declaração da Classe que pega do Banco e do DataTable necessário
                    ClsBanco objBanco = new ClsBanco();
                    string retornoInativar = objBanco.InativarFuncionario(cnpj, senhaContratante, idFuncionario);

                    // Verificar se foi Inativado
                    if (retornoInativar == "Funcionário desativado com sucesso")
                    {
                        // Caso tenha sido Inativado
                        MessageBox.Show(retornoInativar + "!", "Funcionário Inativado!!!");

                        // Reseta os Controles
                        TxtSenhaContratante.Clear();
                        foreach (var controle in new[] { TxtVerID, TxtVerNome, TxtVerCNPJ, TxtVerSenha, TxtSenhaContratante  })
                        {
                            controle.Clear();
                        }
                        GerarFuncionarios();
                    }
                    else
                    {
                        // Caso não tenha sido Inativado
                        TxtPesquisarNome.Focus();
                        SystemSounds.Beep.Play(); // cria o "beep" padrão
                        MessageBox.Show("Informações inválidas!", "Funcionário não Inativado!!!");
                    }
                }
                else
                {
                    TxtPesquisarNome.Focus();
                    SystemSounds.Beep.Play(); // cria o "beep" padrão
                    MessageBox.Show("Selecione um funcionário antes!", "ATENÇÃO!!!");
                }
            }
            catch (Exception ex)
            {
                // Caso algo dê errado, geralmente quando a conexão com o Banco deu errado
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Verifique a sua conexão com o Banco!", "ATENÇÃO!!!");
            }
        }


        //----------Evento Tick dos Elementos----------
        // Timer da Lista dos Funcionarios
        private void tmListaFunc_Tick(object sender, EventArgs e)
        {
            GerarFuncionarios();
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
        //-----------Gerar dinamicamente os funcionarios----------
        private void GerarFuncionarios()
        {
            try
            {
                // Declaração da Classe que pega do Banco e do DataTable necessário
                ClsBanco objBanco = new ClsBanco();
                DataTable dtFuncionarios = objBanco.ConsultaFuncionarios(Funcionario.Cnpj.ToString());

                // Para verificar se houve Alterações nos Funcionários antes de Gerar tudo de novo
                bool houveAlteracao = false;
                if (funcionarios.Count == dtFuncionarios.Rows.Count)
                {
                    for (int i = 0; i < dtFuncionarios.Rows.Count; i++)
                    {
                        if (funcionarios[i].Name != dtFuncionarios.Rows[i]["Funcionar_Rec"].ToString())
                        {
                            houveAlteracao = true;
                            break;
                        }
                    }
                }
                else
                {
                    houveAlteracao = true;
                }

                if (houveAlteracao)
                {
                    // Reseta os Controles
                    funcionarios.Clear();
                    PnlVerFuncionarios.Controls.Clear();
                    foreach (var controle in new[] { TxtVerID, TxtVerNome, TxtVerCNPJ, TxtVerSenha, TxtSenhaContratante })
                    {
                        controle.Clear();
                    }

                    // Verificar se tem Funcionários Ativos
                    if (dtFuncionarios.Columns.Count <= 1)
                    {
                        return;
                    }

                    // Para ajustar o Comprimento dos Botões de acordo com o scroll
                    int larguraBotao = PnlVerFuncionarios.Width;
                    if (dtFuncionarios.Rows.Count > 9)
                    {
                        larguraBotao -= SystemInformation.VerticalScrollBarWidth; // ajuste para scroll
                    }

                    // For para criar todos os Botões dinamicamente
                    for (int i = 0; i < dtFuncionarios.Rows.Count; i++)
                    {
                        // Declaração das variáveis mais comuns
                        String idFuncionario = dtFuncionarios.Rows[i]["Funcionar_Rec"].ToString();
                        String nomeFuncionario = dtFuncionarios.Rows[i]["Nome_Funcionario"].ToString();
                        String tipoFuncionario = dtFuncionarios.Rows[i]["Tipo_Funci"].ToString();

                        // Diminuir Nome do Funcionário
                        if (nomeFuncionario.Count() > 13)
                        {
                            nomeFuncionario = $"{nomeFuncionario.Substring(0, 13)}";
                        }
                        nomeFuncionario.Trim();

                        // Escrever tipo Funcionário
                        switch (tipoFuncionario)
                        {
                            case "Funcionário Saúde":
                                tipoFuncionario = "F";
                                break;
                            case "Administrador Hospital":
                                tipoFuncionario = "A";
                                break;
                            default:
                                tipoFuncionario = "I";
                                break;
                        }

                        // Criar Button
                        Button botao = new Button();
                        Control controle = botao as Control;
                        botao.Text = $"{nomeFuncionario} - {tipoFuncionario}";
                        botao.Width = larguraBotao;
                        botao.Height = 45;
                        botao.Left = 0;
                        botao.Top = i * 45;
                        botao.Name = $"{idFuncionario}";
                        botao.Cursor = Cursors.Hand;

                        // Estilo flat
                        botao.FlatStyle = FlatStyle.Flat;
                        botao.FlatAppearance.BorderSize = 0;
                        botao.FlatAppearance.MouseDownBackColor = Color.FromArgb(230, 230, 230);
                        botao.FlatAppearance.MouseOverBackColor = Color.FromArgb(205, 205, 205);
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

                            GerarReceitasEmitidas(int.Parse(botao.Name));
                        };

                        // Aplicar fonte personalizada nos botões
                        FonteUtils.AplicarFonte(controle, "Inter-Regular", 14f, FontStyle.Regular);

                        // Adicionar button na lista de buttons
                        funcionarios.Add(botao);

                        // Adicionar button no panel
                        PnlVerFuncionarios.Controls.Add(botao);
                    }
                }
            }
            catch (Exception ex)
            {
                // Caso algo dê errado, geralmente quando a conexão com o Banco deu errado
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Verifique a sua conexão com o Banco!", "ATENÇÃO!!!");
            }
        }


        //-----------Gerar dinamicamente as Receitas Emitidas----------
        private void GerarReceitasEmitidas(int idFuncionario)
        {
            try
            {
                // Reseta os Controles
                receita.Clear();
                PnlReceitasEmitidas.Controls.Clear();

                // Declaração da Classe que pega do Banco e do DataTable necessário
                ClsBanco objBanco = new ClsBanco();
                DataTable dtReceitas = objBanco.ConsultaReceitaFunc(idFuncionario);

                // Verificar se tem Receitas Emitidas
                if (dtReceitas.Columns.Count <= 1)
                {
                    return;
                }

                // Para ajustar o Comprimento dos Botões de acordo com o scroll
                int larguraBotao = PnlReceitasEmitidas.Width;
                if (dtReceitas.Rows.Count > 12)
                {
                    larguraBotao -= SystemInformation.VerticalScrollBarWidth; // ajuste para scroll
                }

                // For para criar todos os Botões dinamicamente
                for (int i = 0; i < dtReceitas.Rows.Count; i++)
                {
                    receita.Add(new Receita(dtReceitas, i));

                    // Declaração das variáveis mais comuns
                    String idReceita = dtReceitas.Rows[i]["ID_Receita"].ToString();
                    DateTime dataReceita = DateTime.Parse(dtReceitas.Rows[i]["Data_Receita"].ToString());
                    String data = dataReceita.ToString("dd/MM/yyyy");
                    String horario = dataReceita.ToString("HH:mm:ss");

                    // Criar Label
                    Button botao = new Button();
                    Control controle = botao as Control;
                    botao.Text = $"Receita {idReceita}  {data}  {horario}";
                    botao.Width = larguraBotao;
                    botao.Height = 30;
                    botao.Left = 0;
                    botao.Top = i * 30;
                    botao.Margin = Padding.Empty;
                    botao.Padding = Padding.Empty;
                    botao.TextAlign = ContentAlignment.MiddleCenter;
                    botao.Name = $"{i}";
                    botao.Cursor = Cursors.Hand;

                    // Estilo flat
                    botao.FlatStyle = FlatStyle.Flat;
                    botao.FlatAppearance.BorderSize = 0;
                    botao.FlatAppearance.MouseDownBackColor = Color.FromArgb(230, 230, 230);
                    botao.FlatAppearance.MouseOverBackColor = Color.FromArgb(205, 205, 205);
                    botao.BackColor = Color.White;
                    botao.ForeColor = Color.Gray;

                    // Borda desenhada à mão
                    if (dtReceitas.Rows.Count > 12 && i == dtReceitas.Rows.Count - 1)
                    {
                        botao.Paint += (s, f) =>
                        {
                            EstiloUtils.DesenharBorda(f, s, 2, false, false, false, true, Color.FromArgb(64, 0, 0, 0));
                        };
                    }
                    else
                    {
                        botao.Paint += (s, f) =>
                        {
                            EstiloUtils.DesenharBorda(f, s, 2, false, true, false, true, Color.FromArgb(64, 0, 0, 0));
                        };
                    }

                    // Clique do botão
                    botao.Click += (s, f) =>
                    {
                        // Variável sobre as Coordenadas do Forms
                        Valores valores = new Valores();

                        // Criar a Receita do lado da Tela Principal
                        Point ponto = new Point(this.Location.X + this.Width - 16, this.Location.Y);

                        // Para verificar já existe um Chat aberto, antes de abrir um novo
                        if (objTelaReceita == null || objTelaReceita.IsDisposed)
                        {
                        }
                        else
                        {
                            objTelaReceita.Close();
                        }

                        // Para verificar se as Coordenadas da Receita anterior não são Vazias
                        if (valores.CoordenadaReceita != new Point())
                        {
                            // Para pegar o valor Anterior das Coordenadas do Chat
                            ponto = valores.CoordenadaReceita;

                            // Registra o Valor das Coordenadas igual ao valor anterior do ponto
                            valores.CoordenadaReceita = new Point(this.Location.X + this.Width - 16, this.Location.Y);
                        }
                        else
                        {
                            // Registra o Valor das Coordenadas igual ao ponto
                            valores.CoordenadaReceita = ponto;
                        }

                        // Cria o Forms do Chat 
                        objTelaReceita = new TelaReceita(receita[int.Parse(botao.Name)]);
                        objTelaReceita.StartPosition = FormStartPosition.Manual;
                        objTelaReceita.Location = ponto;
                        objTelaReceita.Show();
                    };

                    // Aplicar fonte personalizada nos labels
                    FonteUtils.AplicarFonte(controle, "Inter-Regular", 12f, FontStyle.Regular);

                    // Adicionar label no panel
                    PnlReceitasEmitidas.Controls.Add(botao);
                }
            }
            catch (Exception ex)
            {
                // Caso algo dê errado, geralmente quando a conexão com o Banco deu errado
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Verifique a sua conexão com o Banco!", "ATENÇÃO!!!");
            }
        }


        //----------Função de Cadastrar Funcionário----------
            private void CadastrarFuncionario()
        {
            try
            {
                // Para verificar se o controle está vazio, e então deixar esse controle em Focus()
                foreach (var controle in new[] { TxtNomeFuncionario, TxtCNPJ, TxtSenhaFunc })
                {
                    if (string.IsNullOrWhiteSpace(controle.Text))
                    {
                        controle.Focus();
                        SystemSounds.Beep.Play(); // cria o "beep" padrão
                        MessageBox.Show("Preencha todos os campos!", "ATENÇÃO!!!");
                        return;
                    }
                }

                // Verificar qual foi o Tipo de Funcionario selecionado
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

                // Para verificar se o controle está vazio, e então deixar esse controle em Focus()
                if (string.IsNullOrWhiteSpace(CmBoxTipoFunc.Text) || idTipo == 0)
                {
                    CmBoxTipoFunc.Focus();
                    SystemSounds.Beep.Play(); // cria o "beep" padrão
                    MessageBox.Show("Preencha todos os campos!", "ATENÇÃO!!!");
                    return;
                }

                // Declaração das variáveis mais comuns
                string cnpj = TxtCNPJ.Text;
                int idTipoFuncionario = idTipo;
                string nomeFuncionario = TxtNomeFuncionario.Text;
                string senhaFuncionario = TxtSenhaFunc.Text;
                string senhaAdministrador = TxtSenhaAdmin.Text;

                // Declaração da Classe que pega do Banco e do DataTable necessário
                ClsBanco objBanco = new ClsBanco();
                DataTable retornoLogin = objBanco.LoginFuncionario(Funcionario.Id, senhaAdministrador);

                // Verificar se o login é Válido
                if (retornoLogin.Columns.Count > 1)
                {
                    // Declaração da Classe que pega do Banco e do DataTable necessário
                    objBanco = new ClsBanco();
                    string retornoCadastro = objBanco.CadastroFuncionario(cnpj, idTipoFuncionario, nomeFuncionario, senhaFuncionario);

                    // Verificar se o Cadastro foi inválido
                    if (retornoCadastro == "Funcionário registrado com sucesso")
                    {
                        // Caso o Cadastro tenha sido Válido
                        MessageBox.Show(retornoCadastro + "!", "Cadastro Sucedido!!!");

                        // Reseta os Controles
                        foreach (var controle in new[] { TxtNomeFuncionario, TxtCNPJ, TxtSenhaFunc, TxtSenhaAdmin })
                        {
                            controle.Text = "";
                        }
                        CmBoxTipoFunc.SelectedIndex = 0;
                        TxtNomeFuncionario.Focus();
                    }
                    else
                    {
                        // Caso o Cadastro tenha sido Inválido
                        TxtNomeFuncionario.Focus();
                        SystemSounds.Beep.Play(); // cria o "beep" padrão
                        MessageBox.Show("Informações inválidas!", "Cadastro não Sucedido!!!");
                    }
                }
                else
                {
                    // Caso o Login seja Inválido
                    TxtSenhaAdmin.Focus();
                    SystemSounds.Beep.Play(); // cria o "beep" padrão
                    MessageBox.Show("Verifique as credenciais inseridas!", "Funcionário não identificado!!!");
                }
            }
            catch (Exception ex)
            {
                // Caso algo dê errado, geralmente quando a conexão com o Banco deu errado
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Verifique a sua conexão com o Banco!", "ATENÇÃO!!!");
            }
        }
    }
}