Classroom CMS
===============

For my second App I made an app to handle the submitting and posting of work in a classroom using Ruby on Rails in a traditional MVC (Model View Controller) style.  My app allows users to log in securely with their github account and then view their assignments and submit individual work.  I used a pretty normal Rails setup.  There's a PostgresSQL database hooked up to some ActiveRecord models and Controllers.  For the view component I used ERB (Embedded RuBy) templates that are bundled with Rails.  The only external libraries I used were Github Omniauth to handle the logins and a ruby gem called redcarpet to translate .md files into properly displayed HTML.  I found the development to very smooth and easy.  Every library is well documented, well established and everything pretty much works out of the box.  I've worked with rails a couple times and it's always very quick and easy to get an app up and running.  This is in stark contrast to the Dapp development environment with Ethereum, where everything is constantly in flux and most of my time was spent figuring out how to get the different libraries to be compatible at a basic level.

Let's start out by discussing the MVC paradigm and how it differs from Ethereum development.  In the MVC paradigm, program logic is separated into distinct pieces.  "Models" in Rails are essentially objects built to manage the data in an application, they have methods to hook up and perform CRUD actions on a specific database table.  "Views" are the display components that users see and interact with.  Rails ships with ERB templates, but it's possible to use straight html, some javascript framework or whatever you'd like to display information to the user.  "Controllers" are the middle-men between the models and the views.  Any time a user interacts with a view, the controller handles the request, updates and fetches data through the models, then updates the views so the user can see the change.

<MVC screenshot>

This paradigm typically results in one monolithic server that handles all requests and keeps track of all data in one centralized repository.  This can sometimes be a problem as businesses scale, they need to find strategies to reduce server load so there isn't one bottleneck.  I'd also argue that this paradigm results in the centralized control of a lot of user data.  The way I built my Ethereum app doesn't differ too far from this paradigm, but it has one key difference.  I used the Ethereum blockchain and my deployed factory contract as the database and models, the Web3 library as my controller and a React front-end as the view.  The key difference was that data saved on the Ethereum blockchain is distributed across many machines and I don't have direct control to access or alter it.  This is a big difference, but there is more decentralization that can be done.  There are some interesting technologies in development I didn't get a chance to explore that would let me distribute my react front-end in a decentralized manner across a number of participating nodes. [https://ipfs.io/](https://ipfs.io/)

For me database I used PostgresSQL, for no other reason than its one option that ships with rails and I'm familiar with it from launch.  PostgresSQL is an open-source version of SQL, a popular relational database.  In SQL databases information is saved in a set of tables, that have explicit relationships, or connections to one another.  For my database I had three tables, a user table with login information including email, username, password etc, an assignment table that includes a title and an assignment description, and a studentWork table with the id of the student, the id of the assignment it was for, and the text of the work.  The studentWork table is what is often called a "join" table, because it contains the foreign keys of 2 other tables, so it is possible to both view which student wrote the work and which assignment it was for.  Given a student it is possible to see all the assignments that student has submitted work for, and given an assignment it is possible to see all the students who have submitted work for that assignment by making a query through the join table.  Another way to think about the relationships is that students have a one to many relationship with studentWork and assignments have a one to many relationship to studentWork.  Below is an ER diagram (Entity Relation) that visually shows the layout of my database.

<ERB Diagram>

To create and manage my database I used the built in ORM (Object Relational Mapping) Rails uses called ActiveRecord.  To build the database tables I wrote what are called "migrations".  I currently have on migration per table that lists each row stored in the table along with any constraints for that row.  If I ever wanted to change a table I'd simply write another migration file and run it from the console with the command rake db:migrate.  Here's my migration for studentWorks:

```ruby
class CreateStudentworks < ActiveRecord::Migration[5.2]
  def change
    create_table :studentworks do |t|
      t.string :work
      t.references :user, foreign_key: true, null: false
      t.references :assignment, foreign_key: true, null: false

      t.timestamps
    end
  end
end
```

After migrations are run and the table are created, Rails automatically generates a schema file we can use as a reference for what our database contains.  Next, for each table we are required to make a corresponding model in the models folder with a very specific name scheme.  For the database table labeled "assignments" I need to make a model named "assignment.rb", the singular of the plural table.  This can get irritating if you aren't familiar with Rails conventions.  In the models themselves we write any relationships between the database tables with helper methods from ActiveRecord - has_many and belongs_to.  We can also include methods for initializing a table or methods callable from our controller for handling data retrieved or sent to the models.  My studentWork model is very simple, it belongs_to users and belongs_to assignments because it is a join table with 2 many-to-one relationships.

```ruby
class Studentwork < ApplicationRecord
  belongs_to :assignment
  belongs_to :user
end
```

Next I wrote controllers to handle retrieving and updating information from my database through my models.  I have an assignments_controller for dealing with assignments, a studentWorks controller for handling studentWorks and a sessions controller for handling user log-in sessions.  In this case the naming convention has less to do with our model names and more to do with how we set up our routes, which I will talk about later.  Most of the back-end logic for our app is in the controllers.  In the assignments controller we have the following methods: index, new, show, create, edit, update and destroy.  These roughly correspond to each CRUD action as well as a way to display all assignments in our database in our index method, or one specific assignment in our show method.  Below are two of these methods, the show method and the create method.

```ruby
def show
  @assignment = Assignment.find(params[:id])
  @user = current_user
  if Studentwork.all != []
    if @user.role == "admin"
      @studentworks = Studentwork.where(assignment_id: @assignment.id)
    end
    if @user.role == "student"
      @work = Studentwork.where(user_id: @user.id).take
    end
  end
end

def create
  @assignment = Assignment.new(assignment_params)
  @user = current_user

  if @assignment.save
    flash[:notice] = "assignment created successfully"
    redirect_to assignments_path
  else
    @form_errors = @assignment.errors.full_messages
    render :new
  end
end
```

In the show method, a user has clicked on a specific assignment and the id of that assignment is in the params hash.  The method first assigns a class variable to equal the entry i the database where the id sent from params is equal to the assignment id, then it checks if the user is an admin or a student.  If they are an admin - all studentWork for the assignment is saved to an instance variable to be rendered on the page, if they are a student just their work is assigned to be rendered.  In the create method, a new assignment is created using information sent from a form in the view.  Information to create a new assignment is handled by the helper method assignment_params, and an entry is added to the database by utilizing the Assignment model.  If it successfully saves, they are redirected back to the homepage, if it does not successfully save, error messages are rendered to the page the form was sent from.

Rails has a fairly intuitive built-in routing system.  There's a routes.rb file in the config folder where routes are defined.  Each route is defined arbitrarily and is handled by default by a controller with the same name.  It is somewhat conventional to name your routes/controllers similar to your database models but not strictly necessary.  In my app I have a handful of very explicitly defined routes for handling the creation of sessions and the user database that I got from this article: [https://richonrails.com/articles/github-authentication-in-ruby-on-rails](https://richonrails.com/articles/github-authentication-in-ruby-on-rails).  Theres an "/auth/:provider/callback" url that is handled by the create method in the sessions controller, an "auth/failure" route redirected to the homepage and a signout route handled by the sessions destroy method.  root to: defines which controller and method will handle the "/" address.  In this case, the index method in my assignments controller.  

The rest of the routes are defined using rails defaults.  Resources :assignments will create 7 routes handled by the assignments controller.  These include: GET assignments/ POST /new GET /new PATCH /:id/edit DELETE /:id GET /:id PUT /:id.  These get handled by the methods defined in the assignments controller that you might expect.  POST /new is handled by the create method, DELETE /:id is handled by the destroy method, etc.  One thing to note is that any route defined with a : is a dynamic route that will contain params designated by the url in the view.  For instance the URL for GET /:id will be the id of the assignment clicked on and will be handled by the previously discussed show method.  Resources :studentworks defines the same routes for the studentworks controller, except that each studentworks page is nested inside of an assignment/:id.  For instance /assignments/7/studentworks/1 would be the work submitted by a user with the id of 1 for the assignment with the id of 6 and it would be handled by the show method of the studentworks controller.

```ruby
Rails.application.routes.draw do
  get "/auth/:provider/callback", to: "sessions#create"
  get 'auth/failure', to: redirect('/')
  delete 'signout', to: 'sessions#destroy', as: 'signout'
  root to: 'assignments#index'

  resources :assignments do
    resources :studentworks do
    end
  end
end
```

The last piece to discuss are the views.  Views live in the views folder and are nested inside a folder that corresponds with the name of the controller that handles them.  For instance, the assignments controller will by default look for a file in the view/assignments folder labeled index.html.erb to render using the index method when the route corresponds to /assignments.  Here's an example of a view, it's the homepage, rendered at /assignments:

```ruby
<% if current_user.blank? %>
  <h1>Please Sign In</h1>
  <%= link_to 'Sign In with Github', '/auth/github' %>
<% else %>
  <% @assignments.each do |assignment| %>
    <h1 class="assignment-link"><%= link_to assignment.title, assignment_path(assignment.id) %></h1>
    <% end %>
      <% if current_user.role == "admin" %>
      <p><%= link_to "Add A New Assignment", new_assignment_path %></p>
    <% end %>
<% end %>
```

I used the ERB templating language, which lets us embed ruby code into html (or XML, plaintext/any other file extension) using <% %> and <%= %> tags [https://ruby-doc.org/stdlib-2.6.3/libdoc/erb/rdoc/ERB.html](https://ruby-doc.org/stdlib-2.6.3/libdoc/erb/rdoc/ERB.html).  In this case we are calling the current_user method which we define in our application_controller (that all controllers inheret fron) to check if the user is currently logged in, then we conditionally render a list of assignments.  The instance variable @assignments we define in our assignments controller as a list off all assignments in our database and it is available here.  We loop through the list and create a link, with the rails helper method link_to, that corresponds to the title of each assignment.  The URL will be passed the id as params and that individual assignment will be rendered on the assignments show page.  We also check if the user is currently in admin, then include a link to create a new assignment if they are.  This will link to the view in assignments/new, which consists of a form for creating a new assignment, and be handled by the create method in our assignments controller.  This pattern persists throughout our app, where admins and students are given access to different elements to view and interact with.  One thing to note in the above code is the difference between <% and <%=.  The output of ruby code after <%= will be displayed on the page where just the logic will be run inside <% %>.

In my app I only use two external libraries not packaged in Rails.  Those are the Github omniauth library for authenticating users with their github account and the redcarpet library for properly displaying markdown.  In Ruby, outside libraries are packaged in "gems".  A list of dependencies are included in the gemfile.  To install outside libraries in Rails is as easy as gem install <library name>.  I make heavy use of the omniauth library in my sessions controller and users model to manage sessions/logins.  In fact most of my code for those files were simply taken from the setup article.  I make heavy use of redcarpet to render assignments and studentworks in my assignments and studentworks show views.  Here's my studenworks show view:

```ruby
<h1><%=@studentwork.user.username + "'s work"%></h1>
<p><%=markdown(@studentwork.work)%></p>
<p><%=link_to "Edit", edit_assignment_studentwork_path(@assignment.id, @studentwork.id)%></p>
```

I wrote a method in /helpers/application_helper.rb that takes a string and interprets it as markdown, then outputs html.  Calling it in my view is as simple as markdown("string").  Here it's translating the specific studentwork available on this show-page.[https://github.com/vmg/redcarpet](https://github.com/vmg/redcarpet)

I wanted to make this app as a proof of concept and demonstrate my understanding of a basic MVC architecture with user authentication and conditional rendering.  If I had more time I would add in a lot more css in the stylesheets folder, all I did was style the navbar to make it a little navbarry.  I would also include some rspec unit tests for my models and capybara acceptance tests for my views.  Developing with Rails in a stable environment was a pleasure.  It's amazing how much smoother the process was than trying to develope an app with Ethereum.  I hope the tooling get's there someday for Dapps but right now building things the traditional way with is maybe 10x easier.
