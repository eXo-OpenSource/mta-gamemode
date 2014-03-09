{include file='documentHeader'}
<head>
	<title>{lang}wcf.page.vrp.blog.title{/lang} - {PAGE_TITLE|language}</title>

	{include file='headInclude' sandbox=false}
</head>

<body id="tpl{$templateName|ucfirst}">
	{include file='header'}

	<header class="boxHeadline">    
		<h1>{lang}wcf.page.vrp.blog.title{/lang}</h1>  
	</header>

	{include file='userNotice'}

	<div class="container marginTop">
		<ul class="containerList exampleList">
			<li class="exampleBox">
				<div>
					<div class="containerHeadline">
						<h3>{lang}wcf.page.vrp.blog.secondTitle{/lang}</h3>
						<p>{lang}wcf.page.vrp.blog.content{/lang}</p>
					</div>
				</div>
			</li>
		</ul>
	</div>

	{include file='footer'}
</body>
</html>