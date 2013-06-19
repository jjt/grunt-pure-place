grunt-pure-place
================

A Grunt plugin that turns [Pure](http://purecss.io/)'s `.pure____` classes in `src/**/css/*.css` into
`%pure____` [Sass placeholders](http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html#placeholder_selectors_)
in `scss/**/_*.scss`. Also produces scss files with the Pure classes so you can import them and use them
in your html as well.

See [pure-place](https://github.com/jjt/pure-place), a fork of Pure that has had `grunt-pure-place`
run against it with ready-to-use scss placeholders.

### Sample Output  

src/tables/css/tables.css   

    .pure-table-striped tr:nth-child(2n-1) td {
        background-color: #f2f2f2;
    }
    
    .pure-table-bordered td {
        border-bottom: 1px solid #cbcbcb;
    }
    .pure-table-bordered tbody > tr:last-child td,
    .pure-table-horizontal tbody > tr:last-child td {
        border-bottom-width: 0;
    }


scss/tables/_tables.scss  

    %pure-table-striped tr:nth-child(2n-1) td {
      background-color: #f2f2f2;
    }
    
    %pure-table-bordered td {
      border-bottom: 1px solid #cbcbcb;
    }
    
    %pure-table-bordered tbody > tr:last-child td,
    %pure-table-horizontal tbody > tr:last-child td {
      border-bottom-width: 0;
    }
