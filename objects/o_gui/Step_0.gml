var i,e,n;

n = ds_list_size(li_textblocks);

for (i=n-1; i>=0; i--)
{
	e = ds_list_find_value(li_textblocks,i);
	e.countdown();
}