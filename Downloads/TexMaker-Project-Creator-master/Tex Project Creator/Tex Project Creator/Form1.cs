using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Tex_Project_Creator
{
    public partial class Form1 : Form
    {
        ProjectUtilities pj;
        public Form1()
        {
            InitializeComponent();
            listView1.GridLines = true;
            pj = new ProjectUtilities();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if(textBox1.Text != "")
            {
                listView1.Items.Add(new ListViewItem(textBox1.Text));
                pj.addChapter(textBox1.Text);
                textBox1.Clear();
            }
        }

        private void project_gen_Click(object sender, EventArgs e)
        {
            if(textBox3.Text != "" && textBox2.Text !="")
            {
                if(checkBox1.Checked && textBox3.Text != "")
                {
                    pj.createTitle = true;
                    pj.Title = textBox3.Text;
                }
                if(checkBox2.Checked)
                {
                    pj.createTable = true;
                }
                if(textBox2.Text != "")
                {
                    pj.Author = textBox2.Text;
                }
                pj.CreateFolderStructure(textBox3.Text);
                pj.CreateChapterFiles();
                pj.CreateMainFile();
            }
            
        }

        private void select_dir_Click(object sender, EventArgs e)
        {
            FolderBrowserDialog fb = new FolderBrowserDialog();
            if(fb.ShowDialog() == DialogResult.OK && !string.IsNullOrWhiteSpace(fb.SelectedPath))
            {
                pj.Path = fb.SelectedPath;
                label4.Text = fb.SelectedPath;
            }
        }

        private void button1_Click_1(object sender, EventArgs e)
        {
            if(listView1.SelectedItems.Count > 0 && checkBox3.Checked)
            {
                ListViewItem lvi = listView1.SelectedItems[0];
                pj.BibChapter = lvi.Text;
                pj.LibNeeded = true;
                lvi.BackColor = Color.Red;
                foreach (ListViewItem lv in listView1.Items)
                {
                    if(lvi != lv)
                    {
                        lv.BackColor = Color.White;
                    }
                }
            }
            else
            {

            }
        }
    }
}
