class Tag {
    [String]$Name
    [String]$Color
    [String]$Comments

    static [String]ColorNameFromCode([String]$color){
        [String]$colorName = $null
        switch ($color){
            'color1'  {$colorName = 'red'; break}
            'color2'  {$colorName = 'green'; break}
            'color3'  {$colorName = 'blue'; break}
            'color4'  {$colorName = 'yellow'; break}
            'color5'  {$colorName = 'copper'; break}
            'color6'  {$colorName = 'orange'; break}
            'color7'  {$colorName = 'purple'; break}
            'color8'  {$colorName = 'gray'; break}
            'color9'  {$colorName = 'light green'; break}
            'color10' {$colorName = 'cyan'; break}
            'color11' {$colorName = 'light gray'; break}
            'color12' {$colorName = 'blue gray'; break}
            'color13' {$colorName = 'lime'; break}
            'color14' {$colorName = 'black'; break}
            'color15' {$colorName = 'gold'; break}
            'color16' {$colorName = 'brown'; break}
        }
        return $colorName
    }

    static [String]ColorCodeFromName([String]$color){
        [String]$colorCode = $null
        switch ($color){
            'red'         {$colorCode = 'color1'; break}
            'green'       {$colorCode = 'color2'; break}
            'blue'        {$colorCode = 'color3'; break}
            'yellow'      {$colorCode = 'color4'; break}
            'copper'      {$colorCode = 'color5'; break}
            'orange'      {$colorCode = 'color6'; break}
            'purple'      {$colorCode = 'color7'; break}
            'gray'        {$colorCode = 'color8'; break}
            'light green' {$colorCode = 'color9'; break}
            'cyan'        {$colorCode = 'color10'; break}
            'light gray'  {$colorCode = 'color11'; break}
            'blue gray'   {$colorCode = 'color12'; break}
            'lime'        {$colorCode = 'color13'; break}
            'black'       {$colorCode = 'color14'; break}
            'gold'        {$colorCode = 'color15'; break}
            'brown'       {$colorCode = 'color16'; break}
        }
        return $colorCode
    }
}
