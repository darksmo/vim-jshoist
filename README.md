## vim-jshoist - v0.1

## Description

This plugin allows you to quickly move a Javascript var declaration to the
closest function scope.

For example, turning this:

```javascript

    function () {

        // ... code ...

        var myname = "myvalue";
    }
```

into this:

```javascript

    function () {
        var myname;

        // ... code ...

        myname = "myvalue";
    }
```

Any comments, corrections and suggestions are welcome.

## Installation

### Dependencies

* No dependencies are required

### Installing without plugin-manager

Download zip [file] (https://github.com/darksmo/vim-jshoist/archive/master.zip)
or clone project. Then copy `plugin` folder from the plugin's directory to your `~/.vim` folder.

``` bash
unzip vim-jshoist-master.zip
cd vim-jshoist-master
cp -r plugin ~/.vim/
```

### Installing using pathogen

```bash
cd ~/.vim/bundle
git clone https://github.com/darksmo/vim-jshoist.git
```

## How to use

1. in normal mode, place the cursor anywhere in a line containing a javascript
   variable declaration.

2. run the command `:JsHoist`

## Configuration

Feel free to configure the plugin to fit your needs. To do this you could,
for example, add the following in your vimrc:

    nnoremap <leader>z :JsHoist<cr>

