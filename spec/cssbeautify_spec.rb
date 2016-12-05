require 'spec_helper'

class String
  def unindent
    gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "")
  end
end

describe CssBeautify do

  it "Simple style" do
    input = <<-eos.unindent
      menu { color: blue; }

      box { border-radius: 4px; background-color: red }
      a { color: green }
      b { color: red }
    eos

    output = CssBeautify.beautify(input)

    expect(output).to eq <<-eos.unindent.strip
      menu {
          color: blue;
      }

      box {
          border-radius: 4px;
          background-color: red
      }

      a {
          color: green
      }

      b {
          color: red
      }
    eos
  end

  it "Block comment" do
    input = <<-eos.unindent
      /* line comment */
      navigation { color: blue }

      menu {
          /* line comment inside */
          border: 2px
      }

      /* block
       comment */
      sidebar { color: red }

      invisible {
          /* block
           * comment
           * inside */
          color: #eee
      }
    eos

    output = CssBeautify.beautify(input)
    expect(output).to eq <<-eos.unindent.strip
      /* line comment */
      navigation {
          color: blue
      }

      menu {
          /* line comment inside */
          border: 2px
      }

      /* block
       comment */
      sidebar {
          color: red
      }

      invisible {
          /* block
           * comment
           * inside */
          color: #eee
      }
    eos
  end

  it "Indentation" do
    input = <<-eos.unindent
          navigation {
        color: blue
      }
    eos

    output = CssBeautify.beautify(input)

    expect(output).to eq <<-eos.unindent.strip
      navigation {
          color: blue
      }
    eos
  end

  it "Blank line and spaces" do
    input = <<-eos.unindent
      /* only one blank line between */
      menu { color: red }




      navi { color: black }

      /* automatically insert a blank line */
      button { border: 1px } sidebar { color: #ffe }

      /* always whitespace before { */
      hidden{opacity:0%}

      /* no blank lines inside ruleset */
      imprint {
        color: blue;


          opacity: 0.5;

         font-size: small
      }

      /* before colon: no space, after colon: one space only */
      footer {
            font-family:     Arial;

        float   :right;
        }
    eos
    output = CssBeautify.beautify(input)

    expect(output).to eq <<-eos.unindent.strip
      /* only one blank line between */
      menu {
          color: red
      }

      navi {
          color: black
      }

      /* automatically insert a blank line */
      button {
          border: 1px
      }

      sidebar {
          color: #ffe
      }

      /* always whitespace before { */
      hidden {
          opacity: 0%
      }

      /* no blank lines inside ruleset */
      imprint {
          color: blue;
          opacity: 0.5;
          font-size: small
      }

      /* before colon: no space, after colon: one space only */
      footer {
          font-family: Arial;
          float: right;
      }
    eos
  end

  it "Quoted string" do
    input = <<-eos.unindent
      nav:after{content:\'}\'}
      nav:before{content:"}"}
    eos

    output = CssBeautify.beautify(input)

    expect(output).to eq <<-eos.unindent.strip
      nav:after {
          content: \'}\'
      }

      nav:before {
          content: "}"
      }
    eos
  end

  it "Selectors" do
    input = <<-eos.unindent
      * { border: 0px solid blue; }
      div[class="{}"] { color: red; }
      a[id=\\"foo"] { padding: 0; }
      [id=\\"foo"] { margin: 0; }
      #menu, #nav, #footer { color: royalblue; }
    eos

    output = CssBeautify.beautify(input)

    expect(output).to eq <<-eos.unindent.strip
      * {
          border: 0px solid blue;
      }

      div[class="{}"] {
          color: red;
      }

      a[id=\\"foo"] {
          padding: 0;
      }

      [id=\\"foo"] {
          margin: 0;
      }

      #menu, #nav, #footer {
          color: royalblue;
      }
    eos
  end

  it "Empty rule" do
    input = "menu{}"
    output = CssBeautify.beautify(input)
    expect(output).to eq <<-eos.unindent.strip
      menu {
      }
    eos
  end

  it "@font-face directive" do
    input = '@font-face{ color:     black; background-color:blue}'
    output = CssBeautify.beautify(input)
    expect(output).to eq <<-eos.unindent.strip
      @font-face {
          color: black;
          background-color: blue
      }
    eos
  end

  it "@import directive" do
    input = <<-eos
      menu{background-color:red} @import url(\'foobar.css\') screen;
      nav{margin:0}
    eos
    output = CssBeautify.beautify(input)
    expect(output).to eq <<-eos.unindent.strip
      menu {
          background-color: red
      }

      @import url(\'foobar.css\') screen;

      nav {
          margin: 0
      }
    eos
  end

  it "@media directive" do
    input = <<-eos
      @import "subs.css";
      @import "print-main.css" print;
      @media print {
        body { font-size: 10pt }
        nav { color: blue; }
      }
      h1 {color: red; }
    eos
    output = CssBeautify.beautify(input)
    expect(output).to eq <<-eos.unindent.strip
      @import "subs.css";

      @import "print-main.css" print;

      @media print {
          body {
              font-size: 10pt
          }

          nav {
              color: blue;
          }
      }

      h1 {
          color: red;
      }
    eos
  end

  it "@media directive (auto-semicolon)" do
    input = <<-eos
      @media screen {
        menu { color: navy }
      }
    eos
    output = CssBeautify.beautify(input, autosemicolon: true)
    expect(output).to eq <<-eos.unindent.strip
      @media screen {
          menu {
              color: navy;
          }
      }
    eos
  end

  it "URL" do
    input = 'menu { background-image: url(data:image/png;base64,AAAAAAA); }'
    output = CssBeautify.beautify(input)
    expect(output).to eq <<-eos.unindent.strip
      menu {
          background-image: url(data:image/png;base64,AAAAAAA);
      }
    eos
  end

  it "Animation keyframe" do
    input = <<-eos
      @-webkit-keyframes anim {
      0% { -webkit-transform: translate3d(0px, 0px, 0px); }
      100% { -webkit-transform: translate3d(150px, 0px, 0px) }}
    eos
    output = CssBeautify.beautify(input)
    expect(output).to eq <<-eos.unindent.strip
      @-webkit-keyframes anim {
          0% {
              -webkit-transform: translate3d(0px, 0px, 0px);
          }

          100% {
              -webkit-transform: translate3d(150px, 0px, 0px)
          }
      }
    eos

  end

end